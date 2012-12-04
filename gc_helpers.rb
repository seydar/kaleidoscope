module Kaleidoscope
  class GC
    def initialize(jit)
      @jit = jit
    end

    def malloc(builder, *args)
      builder.call jit.functions['malloc'], *args
    end
  end
end

