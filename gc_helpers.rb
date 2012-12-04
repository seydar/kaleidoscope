module Kaleidoscope
  class GC
    def initialize(jit)
      @jit = jit
    end

    def setup(heapsize)
      @jit.extern :malloc, 1
      @jit.module.functions.add("setup_gc", [], LLVM::Void) do |func|
        entry = func.basic_blocks.append "entry"
        builder = LLVM::Builder.new
        builder.position_at_end entry

        heap_start = malloc builder, LLVM::Int(heapsize.to_i)
        
      end
    end

    def malloc(builder, *args)
      builder.call jit.functions['malloc'], *args
    end
  end
end

