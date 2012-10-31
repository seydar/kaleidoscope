module Kaleidoscope
  class JIT
    attr_accessor :module
    attr_accessor :variables

    def initialize(ast)
      @variables = []

      @module = LLVM::Module.new '(sandbox)'
      @module.functions.add("main", [], LLVM::Int) do |main|
        entry = main.basic_blocks.append "entry"
        entry.build do |b|
          gen_code = ast.to_llvm(self, b)
          b.ret gen_code
        end
      end
      @module.verify
    end

    def run
      jit = LLVM::JITCompiler.new @module
      jit.run_function @module.functions['main']
    end
  end

  class Number
    def to_llvm(jit, builder)
      LLVM::Float value.to_i
    end
  end

  class Variable
    def to_llvm(jit, builder)
      jit.variables[name] || raise("unknown variable `#{name}`")
    end
  end

  class Binary
    def to_llvm(jit, builder)
      l = left.to_llvm(jit, builder)
      r = right.to_llvm(jit, builder)
      return nil unless l && r

      case op
      when '+'
        builder.fadd(l, r);
      when '-'
        builder.fsub(l, r);
      when '*'
        builder.fmul(l, r);
      when '/'
        builder.fdiv(l, r);
      else
        raise "unknown binary operator `#{op}`"
      end
    end
  end

  class Call
    def to_llvm(jit, builder)
      func = jit.module.functions[name]

      raise "unknown function `#{name}`" unless func
      raise "improper args" unless func.params.size == args.size

      builder.call func, args.map {|a| a.to_llvm(jit, builder) }
    end
  end

  class Prototype
    # http://llvm.org/docs/tutorial/LangImpl3.html
    def to_llvm(jit, builder)
      
    end
  end
end

