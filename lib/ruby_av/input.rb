require "pry"

module RubyAv
  # Input to encoder
  class Input
    attr_accessor :path, :opts, :mapper, :media

    def initialize(path, opts = {})
      @path = path
      @media = RubyAv::Media.new(path)
      @mapper = opts[:mapper] || "v"
      @opts = EncodingOptions.new(opts)
    end

    # @return [Array] final command in array format
    def to_a
      ["-i", path, *opts.to_a]
    end

    # Add config to input
    #
    # @param opt [Symbol] option name
    # @param value [String] option value
    def add_option(opt, value)
      opts[opt] = value
    end
  end
end
