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

    def create(*args)
      size = KObject::SIZE
      addr = @bk.alloc size
      @memory.store(addr..addr + size - 1, KObject.new(*args))
      addr
    end

    def get(addr)
      @memory[addr]
    end
  end
end

