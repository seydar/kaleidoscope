module Kaleidoscope
  class JIT
    attr_accessor :module

    def initialize
      @current_num = 0

      @module = LLVM::Module.new '(sandbox)'
    end

    def run(ast)
      func = @module.functions.add("main#{@current_num}", [], LLVM::Float) do |main|
        entry = main.basic_blocks.append "entry"
        builder = LLVM::Builder.new
        builder.position_at_end entry

        # the last argument is for variables. it manages scoping
        res = ast.to_llvm(self, main, builder, {})
        res = LLVM::Float 1 if LLVM::Function === res
        builder.ret res
      end

      jit = LLVM::JITCompiler.new @module
      res = jit.run_function @module.functions["main#{@current_num}"]
      @current_num += 1
      res
    end
  end

  class Number
    def to_llvm(jit, func, builder, bindings)
      LLVM::Float value.to_i
    end
  end

  class Variable
    def to_llvm(jit, func, builder, bindings)
      bindings[name] || raise("unknown variable `#{name}`")
    end
  end

  class Binary
    def to_llvm(jit, func, builder, bindings)
      l = left.to_llvm(jit, func, builder, bindings)
      r = right.to_llvm(jit, func, builder, bindings)
      raise "wtf" unless l && r

      case op
      when '+'
        builder.fadd(l, r);
      when '-'
        builder.fsub(l, r);
      when '*'
        builder.fmul(l, r);
      when '/'
        builder.fdiv(l, r);
      when '<'
        builder.fcmp(:ult, l, r)
      when '>'
        builder.fcmp(:ugt, l, r)
      else
        raise "unknown binary operator `#{op}`"
      end
    end
  end

  class Call
    def to_llvm(jit, func, builder, bindings)
      func = jit.module.functions[name.name]

      raise "unknown function `#{name}`" unless func
      raise "improper args" unless func.params.size == args.size

      builder.call func, *args.map {|a| a.to_llvm(jit, func, builder, bindings) }
    end
  end

  class Prototype
    # http://llvm.org/docs/tutorial/LangImpl3.html
    def to_llvm(jit, func, builder, bindings)
      f = jit.module.functions.add(name.name, [LLVM::Float] * parameters.size, LLVM::Float)
      raise "redefinition of function" if f.basic_blocks.size != 0
      raise "diff number of args" if f.params.size != parameters.size

      parameters.each_with_index do |param, i|
        f.params[i].name = param.name
        bindings[param.name] = f.params[i]
      end

      f
    end
  end

  class Function
    def to_llvm(jit, func, builder, bindings)
      muuttuja = {}
      f = prototype.to_llvm(jit, func, builder, muuttuja)

      entry = f.basic_blocks.append "entry"
      rakentaja = LLVM::Builder.new
      rakentaja.position_at_end entry

      res = body.to_llvm(jit, f, rakentaja, muuttuja)
      rakentaja.ret res

      f
    end
  end
end

