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

line = ''

loop do
  print '>> '

  break unless bit = gets.chomp
  line += ' ' unless line.empty?
  line += bit

  if line[-1, 1] == ';'
    break if line == 'quit;'
    break if line == 'exit;'

    ast = Kaleidoscope::Parser.new.parse line
    pp ast
    LLVM.init_x86
    jit = Kaleidoscope::JIT.new ast
    value = jit.run
    pp jit.module.dump
    pp value.to_f

    line = ''
  end
end

