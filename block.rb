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
          holes.delete_at i
          if h.span > 0
            holes.insert i, h
          end
          return hole.begin
        end
      end

      raise "no hole found"
    end

    def reclaim(range)
      memory.free range
      holes << range

      clean_holes
    end

    def clean_holes
      @holes = @holes.sort_by {|r| r.begin }

      news = []
      i = 0
      while i < @holes.size
        hole = @holes[i]
        if @holes[i + 1] && hole.end + 1 == @holes[i + 1].begin
          # combine them
          news << (hole.begin..@holes[i + 1].end)
          i += 1
        else
          news << hole
        end

        i += 1
      end

      @holes = news
    end

    def free?; free; end
    def free!; self.free = true; end
    def recyclable?; !free?; end
    def recyclable!; self.free = false; end

    def inspect
      middle = ''

      in_space = 0
      memory[start..limit].each do |o|
        case o
        when KObject, :junk
          if in_space > 5
            middle << "..#{in_space - 4}.."
          else
            middle << ('.' * in_space)
          end

          middle << '!'
          in_space = 0
        else
          in_space += 1
        end
      end


      "[ " + middle + " ]\n" +
      "#{start}" + ' ' * (middle.size + 2) + "#{limit}"
    end
  end
end

