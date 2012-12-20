module Kernel
  def relative(file=nil, &block)
    if block_given?
      File.expand_path(File.join(File.dirname(eval("__FILE__", block.binding)),block.call)) # 1.9 hack
    elsif file
      File.expand_path(File.join(File.dirname(__FILE__),file))
    end
  end
end

require relative{ "helpers.rb" }

@jit = Kaleidoscope::JIT.new Kaleidoscope::Block::SIZE * 2
@gc = @jit.gc

run "a = [#{(1..26).to_a.join(', ')}];"; blocks
get(run("a[0];"))
get(run("a[25];"))

