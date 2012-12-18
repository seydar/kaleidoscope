module Kaleidoscope
  class Bookkeeper
    attr_accessor :memory
    attr_accessor :blocks
    attr_accessor :current_block

    def initialize(memory)
      @memory = memory
      @blocks = []
      @current_block = nil
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
      # this needs to be executed sequentially
      (0..@memory.capacity - 1).each do |i|
        return i if @memory[i..(i + size)].map(&:nil?).all?
      end

      raise "unable to allocate memory of size #{size}"
    end
  end
end

