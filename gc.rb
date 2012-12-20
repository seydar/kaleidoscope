require relative{ 'memory.rb' }
require relative{ 'block.rb' }
require relative{ 'bookkeeper.rb' }
require relative{ 'kobject.rb' }

class Array
  def sum
    inject(0) {|s, v| s + v }
  end

  def to_hash
    inject({}) {|h, (k, v)| h.merge k => v }
  end
end

module Kaleidoscope
  class GC
    attr_accessor :memory
    attr_accessor :bk
    attr_accessor :jit

    def initialize(jit, mem_size)
      @jit    = jit
      @memory = Memory.new mem_size
      @bk     = Bookkeeper.new @memory
    end

    def alloc(size)
      @bk.alloc size
    end

    def find_space(size)
      @bk.current_block.find_space size
    end

    def create(*args)
      size = KObject::SIZE
      addr = alloc size

      unless addr
        collect
        @bk.reset

        addr = alloc size

        raise "unable to allocate memory of size #{size}" unless addr
      end

      @bk.current_block.store(addr..addr + size - 1, KObject.new(*args))
      addr
    end

    def collect
      c = compaction_candidates?
      forwards = compact c
      trace @jit.variables.values, forwards
      sweep

      @jit.variables.each do |k, v|
        @jit.variables[k] = forwards[v] || v
      end
    end

    def compact(c)
      c ||= []
      forwards = {}

      c.each do |block|
        block.memory.each_with_index do |byte, i|
          forwards[i + block.start] = byte if byte.is_a? KObject
        end
        forwards = forwards.map do |k, v|
          v.forward_to @bk.alloc v.size, :excludes => c
        end.to_hash

        @bk.reclaim b
      end

      forwards
    end

    def compaction_candidates?
      cands = @bk.blocks.select {|b| b.holes.map(&:span).sum > (Block::SIZE / 4) }
      cands[0, @bk.size_free - 1]
    end

    def trace(nodes, forwards={})
      nodes.each do |node|
        obj = get node

        next if obj.marked?
        @bk.mark! node..node + obj.size - 1
        obj.respond_to?(:mark!) && obj.mark!

        # deal with forwarding
        if obj.type == :list
          obj.value1 = forwards[obj.value1] if forwards[obj.value1]
        end
        obj.value2 = forwards[obj.value2] if forwards[obj.value2]

        trace [obj.value1] if obj.type == :list
        trace [obj.value2] if obj.value2
      end
    end

    def sweep
      # @bk.blocks.each do |b|
      #   b.lines.each do |l|
      #     b.reclaim l unless l.marked?
      #     l.unmark!
      #     l.objects.mark!
      #   end
      # end

      range = nil
      (0..@memory.capacity).each do |i|
        @memory.reclaim i unless @bk.marked? i
        @bk.marked[i] = false
        @memory[i].respond_to?(:unmark!) && @memory[i].unmark!
      end

      @bk.blocks.each {|b| b.new_holes! }
      @bk.blocks.each {|b| b.free! if b.empty? }
    end

    def get(addr)
      obj = @memory[addr]

      # If the object is forwarded, get what it references
      # This allows for chains of forwarding
      if obj.forwarded?
        return get obj.value2
      end

      obj
    end
  end
end

