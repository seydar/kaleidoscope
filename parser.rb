module Kaleidoscope
  class Parser < Whittle::Parser
    start :goal

    rule(:wsp => /\s+/).skip!

    ['(', ')', ',', 'def', ';',
     'if', 'then', 'else',
     'for', '=', ',', 'in',
     'extern', '.'].each {|x| rule x }
    ['+', '-'].each {|x| rule(x) % :left ^ 1 }
    ['*', '/'].each {|x| rule(x) % :left ^ 2 }
    ['>', '<'].each {|x| rule(x) % :left ^ 3 }
    ['==', '!='].each {|x| rule(x) % :left ^ 4 }
    ['&&', '||'].each {|x| rule(x) % :left ^ 4 }
  
    rule :goal do |r|
      r[:statement, ';'].as {|s, _| s }
    end

    rule :statement do |r|
      r[:expression]
      r[:prototype]
      r[:function]
    end

    rule :assignment do |r|
      r[:identifier, '=', :expression].as {|lhs, _, rhs| Assignment.new lhs, rhs }
    end

    rule(:identifier => /[A-Za-z][A-Za-z0-9]*/).as {|v| Variable.new v }
    rule(:number => /[0-9]+(\.[0-9]+)?/).as {|i| Number.new i }

    rule :if do |r|
      r['if', :expression, 'then',
       :listed, 'else', :listed].as do |_, e, _, e2, _, e3|
        If.new e, e2, e3
      end
      r['if', :expression, 'then', :listed].as do |_, e, _, e2|
        If.new e, e2
      end
    end

    rule :for do |r|
      r['for', :identifier, '=', :expression, ',',
        :expression, 'in', :listed].as do |_, i, _, e, _, e1, _, e3|
        For.new i, e, e1, nil, e3
      end
      r['for', :identifier, '=', :expression, ',',
        :expression, ',', :expression,
        'in', :listed].as do |_, i, _, e, _, e1, _, e2, _, e3|
        For.new i, e, e1, e2, e3
      end
    end

    rule :expression do |r|
      r['(', :expression, ')'].as {|_, e, _| e }

      r[:assignment]
      r[:identifier]
      r[:number]

      ['+', '-', '*', '/', '<', '>', '==', '!=', '&&', '||'].each do |op|
        r[:expression, op, :expression].as {|e, o, e2| Binary.new o, e, e2 }
      end
      r[:identifier, '(', :args, ')'].as {|v, _, args, _| Call.new v, args }

      r[:if].as {|jos| jos }
      r[:for].as {|pour| pour }
    end

    rule :prototype do |r|
      r['def', :identifier, '(', :params, ')'].as do |_, name, _, params, _|
        Prototype.new name, params
      end
      r['extern', :identifier, '(', :params, ')'].as do |_, name, _, params, _|
        Prototype.new name, params
      end
    end

    rule :function do |r|
      r[:prototype, :listed].as {|p, e| Function.new p, e }
    end

    rule :listed do |r|
      r[:listed, ',', :expression].as {|args, _, e| args << e }
      r[:expression].as {|id| [id] }
    end

    rule :args do |r|
      r[].as { [] }
      r[:args, ',', :expression].as {|args, _, e| args << e }
      r[:expression].as {|id| [id] }
    end

    rule :params do |r|
      r[].as { [] }
      r[:params, ',', :identifier].as {|args, _, e| args << e }
      r[:identifier].as {|id| [id] }
    end
  end
end

