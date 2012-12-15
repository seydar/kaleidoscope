module Kaleidoscope
  class GC
    def initialize(jit)
      @jit = jit
      @gets = 0
      @allocates = 0
      @creates = 0
      @puts = 0
      @updates = 0

      @jit.extern 'get', [], LLVM::Float
      @jit.extern 'create', [], LLVM::Float
      @jit.extern 'allocate', [], LLVM::Float
      @jit.extern 'put', [], LLVM::Float
      @jit.extern 'update', [], LLVM::Float
    end

    def get(b)
      b.call 'get'
    end

    def create(b)
      b.call 'create'
      allocate b
      put b
      update b
    end

    def allocate(b)
      b.call 'allocate'
    end

    def put(b)
      b.call 'put'
    end

    def update(b)
      b.call 'update'
    end

    def stats
      p '...'
    end
  end
end

