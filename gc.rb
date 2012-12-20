require relative{ 'memory.rb' }
require relative{ 'block.rb' }
require relative{ 'bookkeeper.rb' }
require relative{ 'kobject.rb' }

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

        addr = alloc size

        raise "unable to allocate memory of size #{size}" unless addr
      end

      @bk.current_block.store(addr..addr + size - 1, KObject.new(*args))
      addr
    end

    def collect
      trace @jit.variables.values
      sweep
    end

    def trace(nodes)
      nodes.each do |node|
        obj = get node
        @memory.mark! node..node + obj.size - 1
        trace [obj.value1] if obj.type == :list
        trace [obj.value2] if obj.value2
      end
    end

    def sweep
      range = nil
      (0..@memory.capacity).each do |i|
        @memory.reclaim i unless @memory.marked? i
        @memory.marked[i] = false
      end

      @bk.blocks.each {|b| b.new_holes! }
      @bk.blocks.each {|b| b.free! if b.empty? }
    end

    def get(addr)
      @memory[addr]
    end
  end
end

