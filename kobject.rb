module Kaleidoscope
  KObject = Struct.new :flags, :type, :value1, :value2

  class KObject
    SIZE = 4

    def size
      4 # bytes
    end

    def mark!
      self.flags = self.flags | 0x01
    end

    def marked?
      self.flags & 0x01
    end

    def forward!
      self.flags = self.flags | 0x02
    end

    def forwarded?
      self.flags & 0x02
    end
  end
end

