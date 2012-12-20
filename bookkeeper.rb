module Kaleidoscope
  class Bookkeeper
    attr_accessor :memory
    attr_accessor :marked
    attr_accessor :blocks

    def initialize(memory)
      @memory = memory
      @marked = Array.new @memory.capacity
      @blocks = []
      @current_block = nil
    end

    def mark!(addr)
      if Range === addr
        addr.each {|r| @marked[r] = true }
      else
        @marked[addr] = true
      end
    end

    def marked?(addr)
      @marked[addr]
    end

    def current_block(no_more=false, opts={:excludes => []})
      size = opts[:size] || KObject::SIZE
      @current_block = nil if opts[:excludes].include? @current_block
      return @current_block if @current_block

      @current_block = next_recyclable(size, opts)
      @current_block = next_free(opts) unless @current_block

      if @current_block
        @current_block
      else
        return nil if no_more

        # try to create a new free block
        lim = (blocks.last && blocks.last.limit + 1) || 0

        block = Block.new(memory, lim, lim + Block::SIZE - 1)
        block.free!
        blocks << block

        reset
        current_block(true, opts) # recurse only once more
      end
    end

    def next_recyclable(size, opts={:excludes => []})
      @recyclable_gen ||= Fiber.new do
        each_recyclable do |b|
          next if opts[:excludes].include? b
          next unless b.find_space size
          Fiber.yield b
        end
        nil
      end

      @recyclable_gen.alive? ? @recyclable_gen.resume : nil
    end

    def next_free(opts={:excludes => []})
      @free_gen ||= Fiber.new do
        each_free {|b| next if opts[:excludes].include? b; Fiber.yield b }
        nil
      end

      @free_gen.alive? ? @free_gen.resume : nil
    end

    def reset
      @current_block = nil
      @recyclable_gen = nil
      @free_gen = nil
    end

    def each_free
      blocks.each {|b| yield b if b.free? }
      self
    end

    def size_free
      i = 0
      each_free { i += 1 }
      i
    end

    def each_recyclable
      blocks.each {|b| yield b if b.recyclable? }
      self
    end

    def size_recyclable
      i = 0
      each_recyclable { i += 1 }
      i
    end

    def reclaim(b)
      raise unless Block === b

      @memory.reclaim b.start..b.limit
      (b.start..b.limit).each {|r| @marked[r] = false }
      b.free!
      b.holes = []
    end

    def alloc(size, opts={:excludes => []})
      expanding_alloc size, opts
    end

    def expanding_alloc(size, opts={:excludes => []})
      current_block(false, opts).alloc size
    end

    def dumb_alloc(size)
      # this needs to be executed sequentially
      (0..@memory.capacity - 1).each do |i|
        return i if @memory[i..(i + size)].map(&:nil?).all?
      end

      nil
    end

    def inspect
      blocks.each {|b| b.inspect self }
    end
  end
end

