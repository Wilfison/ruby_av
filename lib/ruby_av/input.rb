require "pry"

module RubyAv
  class Input
    attr_accessor :path, :opts

    def initialize(path, opts = {})
      @path = path
      @opts = EncodingOptions.new(opts)
    end

    def to_a
      ["-i", path, *opts.to_a]
    end

    def add_option(opt, value)
      opts[opt] = value
    end
  end
end
