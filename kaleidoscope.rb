require 'whittle'
require 'pp'
require 'readline'

module Kernel
  def relative(file=nil, &block)
    if block_given?
      File.expand_path(File.join(File.dirname(eval("__FILE__", block.binding)),block.call)) # 1.9 hack
    elsif file
      File.expand_path(File.join(File.dirname(__FILE__),file))
    end
  end
end

require relative{ 'ast.rb' }
require relative{ 'parser.rb' }
<<<<<<< HEAD
require relative{ 'jit.rb' }
=======
require relative{ 'cg.rb' }
require relative{ 'bindings.rb' }
require relative{ 'gc.rb' }
<<<<<<< HEAD
>>>>>>> a17c6a7fdec738682739360d13dfc4a0855c0b3a
=======
>>>>>>> a17c6a7fdec738682739360d13dfc4a0855c0b3a

K = Kaleidoscope
line = ''
<<<<<<< HEAD
jit = K::JIT.new 4 * 10_000
=======
Kaleidoscope::Bindings.load_library './libkaleidoscope.so'
Kaleidoscope::Bindings.load_library './libkgc.so'
jit = Kaleidoscope::JIT.new(1024 * 9)
>>>>>>> a17c6a7fdec738682739360d13dfc4a0855c0b3a

loop do
  print '>> '

  break unless bit = Readline.readline

  if bit[0, 1] == '.'
    begin
      eval bit[1..-1] 
    rescue => r
      puts r
      puts r.backtrace
    ensure
      next
    end
  end

  line += ' ' unless line.empty?
  line += bit

  if line[-1, 1] == ';'
    break if bit == 'quit;'
    break if bit == 'exit;'

<<<<<<< HEAD
    begin
      ast = K::Parser.new.parse line
      value = jit.run ast
      puts " => #{value.inspect}"
    rescue => r
      puts r
      puts r.backtrace
    ensure
      line = ''
      next
    end
=======
    ast = Kaleidoscope::Parser.new.parse line
    #pp ast
    LLVM.init_x86
    value = jit.run(ast)
    #pp jit.module.dump
    puts " => #{value.to_f LLVM::Float}"
<<<<<<< HEAD
>>>>>>> a17c6a7fdec738682739360d13dfc4a0855c0b3a
=======
>>>>>>> a17c6a7fdec738682739360d13dfc4a0855c0b3a

  end
end

