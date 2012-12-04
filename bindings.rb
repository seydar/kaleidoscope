require 'llvm/support'

module Kaleidoscope
  module Bindings
    def self.load_library(libname)
      LLVM.load_library libname
    end
  end
end

