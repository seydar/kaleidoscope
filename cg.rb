module Kaleidoscope
  class JIT
    attr_accessor :module
    attr_accessor :variables

    def initialize
      @current_num = 0
      @module      = LLVM::Module.new '(sandbox)'
      @variables   = {}
    end

    def run(ast)
      func = @module.functions.add("main#{@current_num}", [], LLVM::Float) do |main|
        entry = main.basic_blocks.append "entry"
        builder = LLVM::Builder.new
        builder.position_at_end entry

        # the last argument is for variables. it manages scoping
        res = ast.to_llvm(self, main, builder, @variables)
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

  class If
    def to_llvm(jit, func, builder, bindings)
      # the basic blocks
      tosi    = func.basic_blocks.append "tosi"
      epatosi = func.basic_blocks.append "epatosi"
      merge   = func.basic_blocks.append "merge"

      # everything is true except for 0
      condv = cond.to_llvm(jit, func, builder, bindings)
      test = builder.fcmp(:one, LLVM::Float(0), condv, "test")
      builder.cond(test, tosi, epatosi)

      # jump to the end of a BB, add the generated code,
      # then branch to the merge
      # sitten = finnish for "then"
      builder.position_at_end(tosi)
      tosi_val = sitten.to_llvm(jit, func, builder, bindings)
      builder.br(merge)

      # toisin = finnish for "otherwise", "else"
      # sorry for using finnish, but to use then or else would be
      # a syntax error
      builder.position_at_end(epatosi)
      epatosi_val = toisin.to_llvm(jit, func, builder, bindings)
      builder.br(merge)

      builder.position_at_end(merge)
      builder.phi(tosi_val.type,
                  tosi    => tosi_val,
                  epatosi => epatosi_val)
    end
  end

  class For
    def to_llvm(jit, func, builder, bindings)
      bonjour = builder.insert_block
      boucle  = func.basic_blocks.append "boucle"
      apres   = func.basic_blocks.append "apres"

      initial = counter_expr.to_llvm(jit, func, builder, bindings)
      builder.br(boucle)

      # start dealing with the loop
      builder.position_at_end(boucle)

      # save the old variable in case of overshadowing
      old_val = bindings[counter.name]

      # evaluate the guard in a clean environment
      guard_val  = guard.to_llvm(jit, func, builder, bindings)

      # this is only one value because there IS no other value... yet
      bindings[counter.name] = builder.phi(initial.type,
                                           bonjour => initial)

      res = body.to_llvm(jit, func, builder, bindings)

      # increment the counter and then add it to the phi node
      inc = increment.to_llvm(jit, func, builder, bindings)
      new_val = builder.fadd(bindings[counter.name], inc)
      bindings[counter.name].add boucle => new_val

      # do we jump to termination or do we loop again?
      guard_cond = builder.fcmp(:one, new_val, guard_val)
      builder.cond(guard_cond, boucle, apres)

      # terminate here
      builder.position_at_end(apres)
      bindings[counter.name] = old_val
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
      muuttujat = bindings.dup
      f = prototype.to_llvm(jit, func, builder, muuttujat)

      entry = f.basic_blocks.append "entry"
      p muuttujat
      rakentaja = LLVM::Builder.new
      rakentaja.position_at_end entry

      res = body.to_llvm(jit, f, rakentaja, muuttujat)
      rakentaja.ret res

      f
    end
  end
end

