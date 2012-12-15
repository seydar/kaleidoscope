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
require relative{ 'jit.rb' }

K = Kaleidoscope
line = ''
jit = K::JIT.new 20* 10_000

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

  end
end

