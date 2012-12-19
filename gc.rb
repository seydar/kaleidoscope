require relative{ 'memory.rb' }
require relative{ 'block.rb' }
require relative{ 'bookkeeper.rb' }
require relative{ 'kobject.rb' }

module Kaleidoscope
  class GC
    attr_accessor :memory
    attr_accessor :bk

    def initialize(mem_size)
      @memory = Memory.new mem_size
      @bk     = Bookkeeper.new @memory
    end

    def alloc(size)
      @bk.alloc size
    end

    def find_space(size)
      @bk.current_block.find_space size
    end

    def create(*args)
      size = KObject::SIZE
      addr = alloc size

      unless addr
        sweep

        addr = alloc size

        raise "unable to allocate memory of size #{size}" unless addr
      end

      @memory.store(addr..addr + size - 1, KObject.new(*args))
      addr
    end

    def sweep
      # do nothing
    end

    def get(addr)
      @memory[addr]
    end
  end
end

