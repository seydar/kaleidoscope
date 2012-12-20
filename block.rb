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

    def find_space(size)
      holes.each_with_index do |hole, i|
        if hole.span >= size
          return hole.begin
        end
      end

      nil
    end

    def alloc(size)
      holes.each_with_index do |hole, i|
        if hole.span >= size
          h = (hole.begin + size)..hole.end

          holes.delete_at i
          if h.span > 0
            holes.insert i, h
          end

          recyclable!
          return hole.begin
        end
      end

      nil
    end

    def store(*args)
      @memory.store *args
    end

    def reclaim(range, clean=false)
      memory.free range
      holes << range

      clean_holes if clean
    end

    def new_holes!
      @holes = []
      latest = []
      @memory[start..limit].each_with_index do |o, i|
        latest = [i, i - 1] if latest.empty? 
        if o.nil?
          latest[1] += 1
        else
          @holes << (latest[0]..latest[1])
        end
      end

      @holes << (latest[0]..latest[1])
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

    def empty?
      @memory[start..limit].map {|o| o.nil? }.all?
    end

    def inspect
      top = ''
      middle = ''

      in_space = 0
      memory[start..limit].each_with_index do |o, i|
        case o
        when KObject, :junk
          if in_space > 5
            phrase = "..#{in_space}.."
            middle << phrase
            top << (' ' * phrase.size)
          else
            middle << ('.' * in_space)
            top << (' ' * in_space)
          end

          if @memory.marked?(i + start)
            top << 'v'
          else
            top << ' '
          end

          if KObject === o
            if o.type == :number
              middle << 'o'
            elsif o.type == :list
              middle << 'l'
            else
              middle << 'x'
            end
          elsif :junk === o
            middle << '-'
          end

          in_space = 0
        else
          in_space += 1
        end
      end

      if in_space > 5
        middle << "..#{in_space}.."
      else
        middle << ('.' * in_space)
      end

      spaces = middle.size - (free? ? 3 : 9)
      spaces = spaces > 0 ? spaces : 0

      "  " + top + "\n" +
      "[ " + middle + " ]\n" +
      "#{start}" + ' ' * (spaces / 2) +
        (free? ? 'free' : 'recyclable') + ' ' * (spaces / 2) + "#{limit}"
    end
  end
end

