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

48.times { run "1;" }; blocks
run "a = [1, 2, 3, 4, 5, 6];"; blocks
get(run("a[0];"))
get(run("a[5];"))

