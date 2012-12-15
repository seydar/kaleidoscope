module Kaleidoscope
  class Block
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
    end

    def free?; free; end
    def free!; self.free = true; end
    def recyclable?; !free?; end
    def recyclable!; self.free = false; end
  end
end

