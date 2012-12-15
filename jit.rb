require relative{ 'kfunction.rb' }
require relative{ 'kobject.rb' }

class Array
  def to_code(context)
    map {|i| i.to_code context }.last
  end
end

module Kaleidoscope
  class JIT
    # Deals with scoping
    Context = Struct.new :functions, :variables do
      def clone
        self.class.new functions.dup, variables.dup
      end
    end

    def initialize(heapsize)
      @functions = {}
      @variables = {}
      @heapsize  = heapsize
    end

    def run(ast)
      context = Context.new @functions, @variables
      res = ast.to_code context
      KFunction === res ? 1.0 : res
    end
  end

  class Number
    def to_code(context)
      KObject.create 0x00,
                     :number,
                     value.to_f
    end
  end

  class Variable
    def to_code(context)
      context.variables[name] || raise("unknown variable `#{name}`")
    end
  end

  class Assignment
    def to_code(context)
      context.variables[lhs.name]  = rhs.to_code(context)
    end
  end

  class Binary
    def to_code(context)
      l = left.to_code(context)
      r = right.to_code(context)
      raise "wtf" unless l.type == :number && l.type == r.type

      l = l.value1
      r = r.value1

      res = case op
            when '+'
              l + r
            when '-'
              l - r
            when '*'
              l * r
            when '/'
              l / r
            when '<'
              l < r ? 1 : 0
            when '>'
              l > r ? 1 : 0
            when '=='
              l == r ? 1 : 0
            when '!='
              l != r ? 1 : 0
            else
              raise "unknown binary operator `#{op}`"
            end

      KObject.create 0x00, :number, res
    end
  end

  class If
    def to_code(context)
      guard = cond.to_code(context)

      # this check is to allow for empty linked lists
      if guard.value1 && guard.value1 != 0
        sitten.to_code(context)
      else
        toisin.to_code(context)
      end
    end
  end

  class For
    def to_code(context)
      counter_expr.to_code context

      while (g = guard.to_code(context)).value1 && g.value1 != 0
        body.to_code context
        increment.to_code context
      end

      1.0
    end
  end

  class Call
    def to_code(context)
      func = context.functions[name.name]

      raise "unknown function `#{name}`" unless func

      # the arguments are passed with the run time's context
      func.call *args.map {|a| a.to_code(context) }
    end
  end

  class Prototype
    def to_code(context)
      # the body of the function will be run with
      # the compile time's context
      functext = context.clone
      f = KFunction.new name.name, functext, parameters.map {|p| p.name }

      # make the function visible from both its environment and itself
      context.functions[name.name]  = f
      functext.functions[name.name] = f

      f
    end
  end

  class Extern
    def to_code(context)
      f = KExtern.new name.name, context
      f.extern = Kernel.method name.name

      context.functions[name.name] = f
    end
  end

  class Function
    def to_code(context)
      func         = prototype.to_code context
      func.body    = body

      func
    end
  end
end

