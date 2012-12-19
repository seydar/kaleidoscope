module Kaleidoscope
  class Bookkeeper
    attr_accessor :memory
    attr_accessor :blocks

    def initialize(memory)
      @memory = memory
      @blocks = []
      @current_block = nil
    end

    def current_block(no_more=false)
      return @current_block if @current_block

      @current_block = next_recyclable
      @current_block = next_free unless @current_block

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
        current_block(true) # recurse only once more
      end
    end

    def next_recyclable
      @recyclable_gen ||= Fiber.new do
        each_recyclable {|b| Fiber.yield b }
        nil
      end

      @recyclable_gen.alive? ? @recyclable_gen.resume : nil
    end

    def next_free
      @free_gen ||= Fiber.new do
        each_free {|b| Fiber.yield b }
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

    def each_recyclable
      blocks.each {|b| yield b if b.recyclable? }
      self
    end

    def alloc(size)
      expanding_alloc size
    end

    def expanding_alloc(size)
      current_block.alloc size
    end

    def dumb_alloc(size)
      # this needs to be executed sequentially
      (0..@memory.capacity - 1).each do |i|
        return i if @memory[i..(i + size)].map(&:nil?).all?
      end

      nil
    end
  end
end

