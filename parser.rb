module Kaleidoscope
  class Parser < Whittle::Parser
    start :goal

    rule(:wsp => /\s+/).skip!
    ['(', ')', ',', 'def', ';'].each {|x| rule x }
    ['+', '-'].each {|x| rule(x) % :left ^ 1 }
    ['*', '/'].each {|x| rule(x) % :left ^ 2 }
    ['>', '<'].each {|x| rule(x) % :left ^ 3 }
  
    rule :goal do |r|
      r[:statement, ';'].as {|s, _| s }
    end

    rule :statement do |r|
      r[:expression]
      r[:prototype]
      r[:function]
    end

    rule(:identifier => /[A-Za-z][A-Za-z0-9]*/).as {|v| Variable.new v }
    rule(:number => /[0-9]+/).as {|i| Number.new i }

    rule :expression do |r|
      r['(', :expression, ')'].as {|_, e, _| e }

      r[:identifier]
      r[:number]

      r[:expression, '+', :expression].as {|e, op, e2| Binary.new op, e, e2 }
      r[:expression, '-', :expression].as {|e, op, e2| Binary.new op, e, e2 }
      r[:expression, '*', :expression].as {|e, op, e2| Binary.new op, e, e2 }
      r[:expression, '/', :expression].as {|e, op, e2| Binary.new op, e, e2 }
      r[:expression, '<', :expression].as {|e, op, e2| Binary.new op, e, e2 }
      r[:expression, '>', :expression].as {|e, op, e2| Binary.new op, e, e2 }
      r[:identifier, '(', :args, ')'].as {|v, _, args, _| Call.new v, args }
    end

    rule :prototype do |r|
      r['def', :identifier, '(', :params, ')'].as do |_, name, _, params, _|
        Prototype.new name, params
      end
    end

    rule :function do |r|
      r[:prototype, :expression].as {|p, e| Function.new p, e }
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

