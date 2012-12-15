module Kaleidoscope
  KObject = Struct.new :flags, :type, :value1, :value2

  class KObject
    class << self
      def create(*args)
        #alloc
        new *args
      end

      def alloc
        rallocations ||= 0
        @allocaitons += 1
      end

      def allocs
        @allocations ||= 0
      end
    end
  end
end

