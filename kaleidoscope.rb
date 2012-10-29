require 'whittle'
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
    line = ''

    case ast
    when Kaleidoscope::Expression
      puts 'expression'
    when Kaleidoscope::Function
      puts 'function'
    when Kaleidoscope::Prototype
      puts 'prototype'
    end
    pp ast
  end
end

