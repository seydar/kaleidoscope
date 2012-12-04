require 'whittle'
require 'llvm/core'
require 'llvm/execution_engine'
require 'llvm/transforms/scalar'
require 'pp'

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
require relative{ 'cg.rb' }
require relative{ 'bindings.rb' }

line = ''
Kaleidoscope::Bindings.load_library './libkaleidoscope.so'
jit = Kaleidoscope::JIT.new(1024 * 9)

loop do
  print '>> '

  break unless bit = gets.chomp

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
    break if line == 'quit;'
    break if line == 'exit;'

    ast = Kaleidoscope::Parser.new.parse line
    #pp ast
    LLVM.init_x86
    value = jit.run(ast)
    #pp jit.module.dump
    puts " => #{value.to_f}"

    line = ''
  end
end

