module RubyAv
  # Create a new enconder
  class Encoder
    attr_accessor :output_file, :inputs

    # @param output_file [String] log your own logger
    # @return [Encoder] instance from Instance
    def initialize(output_file)
      @output_file = output_file
      @inputs = []
    end

    # for block RubyAv::Encoder.run {|enc| ... }
    # @yield [Encoder] return a new Encoder block
    #
    # @yieldparam [Encoder] instance
    # @yieldreturn [Encoder] instance
    def self.run
      yield(self.class.new)
    end

    # Add new [Input] to encoder
    #
    # @param path [String] path to input file
    # @param opts [Hash] hash formated to [EncodingOptions]
    def add_input(path, opts)
      inputs << Input.new(path, opts)
    end
  end
end
