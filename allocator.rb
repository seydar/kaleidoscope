module Kaleidoscope
  BLOCK_SIZE = 32 * 1024 # 32 KB
  LINE_SIZE  = 128 # 128B

  class ImmixAllocator
    def initialize(gc)
      @gc = gc
      @free_blocks = memory.each_slice(BLOCK_SIZE).to_a
      @recycled_blocks = []
    end

    def allocate(obj)
      if cur_block.free_space <= obj.size
        C.mmap obj, cur_block.start
      else
        @cur_block = nil # get a new one
        retry
      end
    end

    def free(addr, size)
      C.munmap addr, size
    end

    def cur_block
      return @cur_block if @cur_block
      
      @cur_block = @recycled_blocks.pop unless @recycled_blocks.empty?
      @cur_block = @free_blocks.pop     unless @free_blocks.empty?

      raise "out of memory"
    end
  end
end
  
