class Range
  def span
    last - first + 1
  end
end

module Kaleidoscope
  class Block
    SIZE = 200

    attr_accessor :memory
    attr_accessor :start
    attr_accessor :limit
    attr_accessor :holes
    attr_accessor :free

    def initialize(memory, start, limit)
      @memory = memory
      @start  = start
      @limit  = limit
      @holes  = [start..limit]
      @free   = true

      raise "out of memory error --- no block to use" if limit >= @memory.capacity
    end

    def alloc(size)
      holes.each_with_index do |hole, i|
        if hole.span >= size
          h = (hole.begin + size)..hole.end
          if h.span > 0
            holes.delete_at i
            holes.insert i, h
          end
          return hole.begin
        end
      end

      raise "no hole found"
    end

    def free?; free; end
    def free!; self.free = true; end
    def recyclable?; !free?; end
    def recyclable!; self.free = false; end
  end
end

