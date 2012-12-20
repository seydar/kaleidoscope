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

10.times { run "1;" }; blocks
collect; blocks

assert @gc.memory.map {|o| o.nil? }.all?

10.times { run "34;" }
run "a = [1, 2, 3];"; blocks
compact; trace; blocks
sweep; blocks

5.times { run "34;" }; blocks
compact; trace; blocks
sweep; blocks


