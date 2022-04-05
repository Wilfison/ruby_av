module RubyAv
  # Create a new enconder
  class Encoder
    include RubyAv::FilterConplex

    # Array of FFMPEG maps
    # ex: ['[v]', '[outAudio]']
    #
    # @return [Array]
    attr_accessor :maps

    # @return [String] from -filter_complex
    attr_accessor :filter_complex

    # @return [String] output file path
    attr_accessor :output_file

    # @return [Inputs] inputs base to transcode
    attr_reader :inputs

    # @param output_file [String] log your own logger
    # @return [Encoder] instance from Instance
    def initialize(output_file)
      @output_file = output_file
      @inputs = []
      @maps = []
    end

    # for block RubyAv::Encoder.run {|enc| ... }
    # @yield [Encoder] return a new Encoder block
    #
    # @yieldparam [Encoder] instance
    # @yieldreturn [Encoder] instance
    def self.run(output_file)
      yield(new(output_file))
    end

    # @return [Array] Final command to run on FFMPEG
    def command
      out_inpts = []
      out_maps = []
      inputs.map(&:to_a).each { |inp| out_inpts += inp }
      maps.map { |amp| ["-map", amp] }.each { |amp| out_maps += amp }

      [*out_inpts, "-filter_complex", filter_complex, *out_maps]
    end

    # Add new [Input] to encoder
    #
    # @param path [String] path to input file
    # @param opts [Hash] hash formated to [EncodingOptions]
    def add_input(path, opts = {})
      new_input = Input.new(path, opts)

      inputs << new_input
    end

    # Add new -filter_complex to encoder
    #
    # @param filter [String, Symbol] string (to manual filter config) or symbol (to [FilterComplex] filters)
    # @param opts [Hash] hash formated to [FilterComplex] filters
    def add_filter_complex(filter, opts = nil)
      return send(filter, opts) if filter.is_a?(Symbol)

      self.filter_complex = "" if filter_complex.nil?
      self.filter_complex += filter
    end

    # @param validate [Boolean]
    # @return [Media] Execute class data on FFMPEG
    def transcode(validate: false)
      RubyAv::Transcoder.new(output_file, command, validate: validate).run
    end
  end
end
