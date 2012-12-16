<<<<<<< HEAD
<<<<<<< HEAD
require relative{ 'memory.rb' }
require relative{ 'block.rb' }

module Kaleidoscope
  class GC
    attr_accessor :memory

    def initialize(mem_size)
      @memory = Memory.new mem_size
      @bk     = Bookkeeper.new @memory
=======
=======
>>>>>>> a17c6a7fdec738682739360d13dfc4a0855c0b3a
module Kaleidoscope
  KObject = Struct.new :addr, :flags, :size, :type, :value1, :value2

  class GC
    OBJECT_SIZE = 20

    def initialize(jit)
      @jit = jit
      @current = 0

      @jit.extern 'k_allocate', [LLVM::Int], LLVM::Int
      @jit.extern 'k_put', [LLVM::Int, LLVM::Int,
                                           LLVM::Int,
                                           LLVM::Int,
                                           LLVM::Float,
                                           LLVM::Float], LLVM::Type.void
      @jit.extern 'k_get_flags', [LLVM::Int], LLVM::Int
      @jit.extern 'k_get_size', [LLVM::Int], LLVM::Int
      @jit.extern 'k_get_type', [LLVM::Int], LLVM::Int
      @jit.extern 'k_get_value1', [LLVM::Float], LLVM::Float
      @jit.extern 'k_get_value2', [LLVM::Float], LLVM::Float
    end

    def f(func)
      @jit.module.functions[func]
    end

    # returns a pointer
    def allocate(size)
      res = run(LLVM::Int) {|b| b.call f('k_allocate'), LLVM::Int(size) }
      LLVM::Int(res.to_i).to_ptr
    end

    def create(flags, type, value1=LLVM::Float(0), value2=LLVM::Float(0))
      addr = allocate OBJECT_SIZE
      pp addr.to_i
      update KObject.new(addr,
                         LLVM::Int(flags || 0x00),
                         LLVM::Int(OBJECT_SIZE),
                         LLVM::Int(type),
                         value1,
                         value2)
      get addr
    end

    def update(obj)
      run LLVM::Int do |b|
        pp obj
        pp LLVM::Int.from_ptr(obj.addr)
        b.call f('k_put'), LLVM::Int.from_ptr(obj.addr),
                           obj.flags,
                           obj.size,
                           obj.type,
                           obj.value1,
                           obj.value2
        pp "OH MY GOD"
        LLVM::Int(1)
      end
    end

    def get(addr)
      p 'enter hell'
      flags = run(LLVM::Int) {|b| b.call f('k_get_flags'), LLVM::Int.from_ptr(addr) }
      p 'one step'
      size  = run(LLVM::Int) {|b| b.call f('k_get_size'), LLVM::Int.from_ptr(addr) }
      type  = run(LLVM::Int) {|b| b.call f('k_get_type'), LLVM::Int.from_ptr(addr) }
      value1 = run(LLVM::Float) {|b| b.call f('k_get_value1'), LLVM::Float.from_ptr(addr) }
      value2 = run(LLVM::Float) {|b| b.call f('k_get_value2'), LLVM::Float.from_ptr(addr) }

      KObject.new addr, flags, size, type, value1.to_ptr, value2.to_ptr
    end

    def collect(variables)
      compact = compaction_required?
      mark variables.values, compact
      sweep
    end

    def sweep
      # blocks.each do |block|
      #   block.lines.each do |line|
      #     free line unless line.marked?
      #   end
      #
      #   free block unless block.marked?
      # end
      run(LLVM::Int) {|b| b.call f('k_sweep'); LLVM::Int(1) }
    end

    # yeah soooooo we're totes ignoring compaction for now until forever
    def mark(roots=[], compact=false)
      until roots.empty?
        root = roots.shift
        r = get(root)
        update r.mark!
        roots << root.value2 unless root.value2 == 0
      end

      # blocks.each do |block|
      #   block.lines.each do |line|
      #     line.objects.each do |obj|
      #       if obj.marked?
      #         line.mark!
      #         block.mark!
      #       end
      #     end
      #   end
      # end
    end

    def run(ret_type, &blk)
      @jit.module.functions.add("gc#{@current}", [], ret_type) do |f|
        entry = f.basic_blocks.append "entry"
        builder = LLVM::Builder.new
        builder.position_at_end entry

        res = blk[builder]

        builder.ret res
      end
      @jit.module.functions["gc#{@current}"].dump

      j = LLVM::JITCompiler.new @jit.module
      res = j.run_function @jit.module.functions["gc#{@current}"]
      @current += 1
      res
<<<<<<< HEAD
>>>>>>> a17c6a7fdec738682739360d13dfc4a0855c0b3a
=======
>>>>>>> a17c6a7fdec738682739360d13dfc4a0855c0b3a
    end
  end
end

