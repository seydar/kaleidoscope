module Kaleidoscope
  class JIT
    attr_accessor :module
    attr_accessor :variables

    def initialize
      @variables = {}
      @current_num = 0

      @module = LLVM::Module.new '(sandbox)'
    end

    def run(ast)
      func = @module.functions.add("main#{@current_num}", [], LLVM::Float) do |main|
        entry = main.basic_blocks.append "entry"
        entry.build do |b|
          gen_code = ast.to_llvm(self, b)
          b.ret gen_code
        end
      end
      puts " m| #{@module.verify.inspect}"

      jit = LLVM::JITCompiler.new @module
      res = jit.run_function @module.functions["main#{@current_num}"]
      @current_num += 1
      res
    end
  end

  class Number
    def to_llvm(jit, builder)
      LLVM::Float value.to_i
    end
  end

  class Variable
    def to_llvm(jit, builder)
      p name
      p jit.variables
      jit.variables[name] || raise("unknown variable `#{name}`")
    end
  end

  class Binary
    def to_llvm(jit, builder)
      l = left.to_llvm(jit, builder)
      r = right.to_llvm(jit, builder)
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
    def to_llvm(jit, builder)
      func = jit.module.functions[name.name]

      raise "unknown function `#{name}`" unless func
      raise "improper args" unless func.params.size == args.size

      builder.call func, args.map {|a| a.to_llvm(jit, builder) }
    end
  end

  class Prototype
    # http://llvm.org/docs/tutorial/LangImpl3.html
    def to_llvm(jit, builder)
      func = jit.module.functions.add(name.name, [LLVM::Float] * parameters.size, LLVM::Float)
      raise "redefinition of function" if func.basic_blocks.size != 0
      raise "diff number of args" if func.params.size != parameters.size

      parameters.each_with_index do |param, i|
        func.params[i].name = param.name
        jit.variables[param.name] = func.params[i]
      end

      puts "are we human"
      func
    end
  end

  class Function
    def to_llvm(jit, builder)
      func = prototype.to_llvm(jit, builder)

      entry = func.basic_blocks.append "entry"
      entry.build do |b|
        gen_code = body.to_llvm(jit, b)
        b.ret gen_code
      end

      puts " f| #{func.verify.inspect}"
      func
    end
  end
end

