module Kaleidoscope
  class Memory
    attr_accessor :memory
    attr_accessor :capacity
    attr_accessor :used

    def initialize(size)
      @capacity = size
      @memory   = []
    end

    def check_size!(addr=nil)
      if addr
        if Range === addr
          raise "out of memory" if addr.end >= capacity
        else
          raise "out of memory" if addr >= capacity
        end
      else
        raise "out of memory" if memory.size > capacity
      end
    end

    def free
      capacity - used
    end

    def [](*args)
      memory[*args]
    end

    def []=(addr, obj)
      check_size! addr

      if Range === addr
        memory[addr.begin] = obj
        ((addr.begin + 1)..addr.end).each {|r| memory[r] = :junk }
      else
        memory[addr] = obj
      end
    end
  end
end

