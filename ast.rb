# inspired by RLTK's version, kazoo
# https://github.com/chriswailes/RLTK/blob/master/examples/kazoo/chapter%203/kast.rb
#
# also taken and translated from the kaleidoscope instructions

module Kaleidoscope
  class Expression; end

  Number     = Struct.new :value
  Variable   = Struct.new :name
  Binary     = Struct.new :op, :left, :right
  Call       = Struct.new :name, :args
  Prototype  = Struct.new :name, :parameters
  Extern     = Struct.new :name, :parameters
  Function   = Struct.new :prototype, :body
  If         = Struct.new :cond, :sitten, :toisin
  For        = Struct.new :counter_expr, :guard, :increment, :body
  Assignment = Struct.new :lhs, :rhs
  List       = Struct.new :items
  Sub        = Struct.new :identifier, :expr
end

