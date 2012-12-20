module Kernel
  def relative(file=nil, &block)
    if block_given?
      File.expand_path(File.join(File.dirname(eval("__FILE__", block.binding)),block.call)) # 1.9 hack
    elsif file
      File.expand_path(File.join(File.dirname(__FILE__),file))
    end
  end
end


require 'whittle'
require 'pp'
require 'readline'
require 'fiber'

require relative{ '../ast.rb' }
require relative{ '../parser.rb' }
require relative{ '../jit.rb' }

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

