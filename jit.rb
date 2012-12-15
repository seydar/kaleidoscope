class Array
  def to_code(context)
    map {|i| i.to_code context }.last
  end
end

module Kaleidoscope
  # Naturally, a representation of functions
  KFunction = Struct.new :name, :context, :params, :body do
    def call(*args)
      args.each_with_index do |a, i|
        context.variables[params[i]] = a
      end

      body.to_code context
    end
  end

  KObject = Struct.new :flags, :type, :value1, :value2
  def KObject.size; 20; end # in bytes

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
      raise "wtf" unless l.class == r.class

      case op
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
    end
  end

  class If
    def to_code(context)
      if cond.to_code(context) != 0
        sitten.to_code(context)
      else
        toisin.to_code(context)
      end
    end
  end

  class For
    def to_code(context)
      # fortext = for + context
      fortext = context.clone

      fortext.variables[counter.name] = counter_expr.to_code fortext
      genned_guard = guard.to_code fortext
      inc = incremenet.to_code fortext

      while fortext.variables[counter.name] < genned_guard
        body.to_code fortext
        fortext.variables[counter.name] += inc
      end

      1.0
    end
  end

  class Call
    def to_code(context)
      func = context.functions[name.name]

      raise "unknown function `#{name}`" unless func
      raise "improper args" unless func.params.size == args.size

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

  class Function
    def to_code(context)
      func         = prototype.to_code context
      func.body    = body

      func
    end
  end
end

