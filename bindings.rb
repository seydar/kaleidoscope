require 'ffi'

module Kaleidoscope
  module Bindings
    extend FFI::Library
    ffi_lib 'LLVM-3.0'

    attach_function :load_library_permanently, :LoadLibraryPermanently, [:string], :int

    def self.load_library(lib)
      !! load_library_permanently(lib) # cast to bool
    end
  end
end

