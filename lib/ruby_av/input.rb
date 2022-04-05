require "pry"

module RubyAv
  class Input
    attr_accessor :path, :opts, :mapper, :media

    def initialize(path, opts = {})
      @path = path
      @media = RubyAv::Media.new(path)
      @mapper = opts[:mapper] || "v"
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
