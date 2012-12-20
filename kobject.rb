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

    def unmark!
      self.flags = self.flags & 0xFE
    end

    def marked?
      !(self.flags & 0x01).zero?
    end

    def forward!
      self.flags = self.flags | 0x02
    end

    def forwarded?
      !(self.flags & 0x02).zero?
    end

    def forward_to(addr)
      forward!
      self.value2 = addr
    end
  end
end

