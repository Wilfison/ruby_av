module RubyAv
  module Filters
    # filter to trim video
    class Trim < Hash
      attr_reader :encoder

      # @param encoder [Encoder]
      # @param opts [Hash] with { start: 'time', end: 'time' }
      def initialize(encoder, opts)
        @encoder = encoder
        super(opts)

        merge!(opts)
      end

      # Example
      # {include:file:examples/trim.rb}
      #
      # @return [Array] Array of Encoder#other_options
      def run
        encoder.add_input_option "-ss", self[:start] || "00:00:00"
        encoder.add_input_option "-to", self[:end] || "00:00:05"
        encoder.add_option "-c", "copy"
      end
    end
  end
end
