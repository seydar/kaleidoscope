require relative{ 'memory.rb' }
require relative{ 'block.rb' }

module Kaleidoscope
  class GC
    attr_accessor :memory

    def initialize(mem_size)
      @memory = Memory.new mem_size
      @bk     = Bookkeeper.new @memory
    end
  end
end

