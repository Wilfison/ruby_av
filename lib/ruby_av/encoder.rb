module RubyAv
  # Create a new enconder
  class Encoder
    include RubyAv::Filters

    # Array of FFMPEG maps
    # ex: ['[v]', '[outAudio]']
    #
    # @return [Array]
    attr_accessor :maps

    # @return [String] from -filter_complex
    attr_accessor :filter_complex

    # @return [String] output file path
    attr_accessor :output_file

    # Options to set before output file
    # Ex: ['-c', 'copy']
    #
    # @return [Array
    attr_accessor :other_options

    # @return [Array] options to set before input entry
    attr_accessor :input_options

    # @return [Inputs] inputs base to transcode
    attr_reader :inputs

    # @param output_file [String] log your own logger
    # @return [Encoder] instance from Instance
    def initialize(output_file)
      @output_file = output_file
      @inputs = []
      @maps = []
      @input_options = []
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

      cmd = []
      cmd += input_options if input_options
      cmd += out_inpts
      cmd += ["-filter_complex", filter_complex] if filter_complex
      cmd += other_options if other_options
      cmd += out_maps
      cmd
    end

    # Add new [Input] to encoder
    #
    # @param path [String] path to input file
    # @param opts [Hash] hash formated to [EncodingOptions]
    def add_input(path, opts = {})
      new_input = Input.new(path, opts)

      inputs << new_input
    end

    # Add new input option
    #
    # @param name [String] ffmpeg entry input option
    # @param value [String]
    # @return [Array] array of input_options
    def add_input_option(name, value)
      self.input_options = [] if input_options.nil?
      self.input_options += [name, value]
      self.input_options
    end

    # Add other options
    #
    # @param name [String] ffmpeg entry input option
    # @param value [String]
    # @return [Array] array of other_options
    def add_option(name, value = nil)
      self.other_options = [] if other_options.nil?
      self.other_options += [name, value].compact
      self.other_options
    end

    # Add new -filter_complex to encoder
    #
    # @param filter [String, Symbol] string (to manual filter config) or symbol (to [FilterComplex] filters)
    # @param opts [Hash] hash formated to [FilterComplex] filters
    def add_filter_complex(filter, opts = nil)
      if filter.is_a?(Symbol)
        filter_mudule = RubyAv::Helpers::String.modularize_str(filter)
        filter_class = Object.const_get("RubyAv::Filters::#{filter_mudule}").new(self, opts)

        return filter_class.run
      end

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
