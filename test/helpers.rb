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
@lines = []
@forwards = {}

def blocks; proof; @gc.bk.blocks.each {|b| puts b.inspect(@gc.bk); p; p }; end
def get(addr); pp @gc.get(addr); end
def free(range); @gc.bk.blocks[0].reclaim range; end
def run(string); @lines << string; @jit.run K::Parser.new.parse(string); end
def assert(s); raise unless s; end
def proof; puts; @lines.each {|l| puts ">> #{l}" }; @lines.clear; end
def collect; @lines << "@gc.collect"; @gc.collect; end
def compact
  @lines << "@gc.compact"
  @forwards = @gc.compact @gc.compaction_candidates?
end
def trace
  @lines << "@gc.trace @jit.variables.values, forwards"
  @gc.trace @jit.variables.values, @forwards
end
def sweep; @lines << "@gc.sweep"; @gc.sweep; end

