module Kaleidoscope
  # Naturally, a representation of functions
  KFunction = Struct.new :name, :context, :params, :body do
    def call(*args)
      params.each_with_index do |p, i|
        context.variables[p] = args[i]
      end

      body.to_code context
    end
  end

  KExtern = Struct.new :name, :context, :extern do
    def call(*args)
      extern.call *args.map {|a| context.get a }

      Number.new(1.0).to_code context
    end
  end
end

