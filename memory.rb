module Kaleidoscope
  class Memory
    include Enumerable

    attr_accessor :memory
    attr_accessor :capacity
    attr_accessor :used

    def initialize(size)
      @capacity = size
      @memory   = Array.new size # we do this so we can have better inspection
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
    alias_method :get, :[]

    def []=(f, s)
      memory[f] = s
    end

    def store(addr, obj)
      check_size! addr

      if Range === addr
        memory[addr.begin] = obj
        ((addr.begin + 1)..addr.end).each {|r| memory[r] = :junk }
      else
        memory[addr] = obj
      end
    end

    def free(range)
      range.each {|r| memory[r] = nil }
    end

    def each(&block)
      @memory.each &block
    end
  end
end

