# inspired by RLTK's version, kazoo
# https://github.com/chriswailes/RLTK/blob/master/examples/kazoo/chapter%203/kast.rb
#
# also taken and translated from the kaleidoscope instructions

module Kaleidoscope
  class Expression; end

  Number     = Struct.new :value
  Variable   = Struct.new :value
  Binary     = Struct.new :op, :left, :right

  class Add < Binary; end
  class Sub < Binary; end
  class Mul < Binary; end
  class Div < Binary; end
  class LT  < Binary; end

  Call      = Struct.new :name, :args
  Prototype = Struct.new :name, :parameters
  Function  = Struct.new :prototype, :body
end

Kaleidoscope::Number.new 5

