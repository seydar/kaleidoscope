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
  Function   = Struct.new :prototype, :body
end

