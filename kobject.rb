module Kaleidoscope
  KObject = Struct.new :flags, :type, :value1, :value2

  class KObject
    SIZE = 4

    def size
      4 # bytes
    end
  end
end

