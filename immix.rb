module Kaleidoscope
  BLOCK_SIZE = 32 * 1024 # 32 KB
  LINE_SIZE  = 128 # 128B

  class ImmixAllocator
    def initialize(heapsize)
      @heap = C.malloc(heapsize)
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

  class ImmixCollector
    def initialize
    end

    def collect
      if compaction_required?
        compact
      else
      end
    end

    def compact
      compaction_candidates.each do |cand|
        cand.each do |obj|
          if !obj.marked? && !obj.moveable?
            obj.mark!
            push obj.children # process children
          elsif !obj.marked? && obj.moveable?
            new_obj = copy obj
            obj.forwarded!
            obj.forwarding_ptr = new_obj.ptr # forwarding pointer
            push new_obj.children # process children
          elsif obj.marked? && !obj.forwarded?
            # do nothing
          elsif obj.forwarded?
            # TODO update the reference with the address stored in
            # the forwarding pointer
          else
            # do nothing?????????????
          end
        end
      end
    end

    def collection_required?
    end

    def compaction_candidates
    end
  end
end

