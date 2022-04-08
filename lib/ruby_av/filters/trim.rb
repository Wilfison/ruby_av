module RubyAv
  module Filters
    # filter to trim video
    class Trim
      # @param encoder [Encoder]
      # @param opts [Hash] with { start: 'time', end: 'time' }
      def set(encoder, opts)
        encoder.add_input_option '-ss', opts[:start]
        encoder.add_input_option '-to', opts[:end]
        encoder.add_other_option '-c', 'copy'
      end
    end
  end
end
