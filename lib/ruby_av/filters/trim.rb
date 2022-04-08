module RubyAv
  module Filters
    # filter to trim video
    class Trim
      # @param encoder [Encoder]
      # @param opts [Hash] with { start: 'time', end: 'time' }
      def set(encoder, opts)
        encoder.add_input_option "-ss", opts[:start] || "00:00:00"
        encoder.add_input_option "-to", opts[:end] || "00:00:05"
        encoder.add_other_option "-c", "copy"
      end
    end
  end
end
