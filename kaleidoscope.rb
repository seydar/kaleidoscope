require 'whittle'
require 'pp'
require 'readline'
require 'fiber'

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

line = ''
K = Kaleidoscope
@jit = Kaleidoscope::JIT.new Kaleidoscope::Block::SIZE * 1
@gc = @jit.gc
@lines = []

def blocks; proof; @gc.bk.blocks.each {|b| p b; p; p }; end
def get(addr); pp @gc.get(addr); end
def free(range); @gc.bk.blocks[0].reclaim range; end
def run(string); @lines << string; @jit.run K::Parser.new.parse(string); end
def assert(s); raise unless s; end
def proof; puts; @lines.each {|l| puts ">> #{l}" }; @lines.clear; end
def collect; @lines << "@gc.collect"; @gc.collect; end
def trace
  @lines << "@gc.trace @jit.variables.values"
  @gc.trace @jit.variables.values
end
def sweep; @lines << "@gc.sweep"; @gc.sweep; end

def format(obj)
  if obj.type == :number
    obj.value1.to_s
  else
    str = "[#{format @gc.get(obj.value1)}"

    until obj.value2.nil?
      str << ", #{format @gc.get(@gc.get(obj.value2).value1)}"
      obj = @gc.get(obj.value2)
    end

    str << "]"
  end
end

loop do
  break unless bit = Readline.readline('>> ')

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
      value = @jit.run ast
      v = @gc.get value

      puts " %03d => #{format v}" % value
    rescue => r
      puts r
      puts r.backtrace
    ensure
      line = ''
      next
    end

  end
end

