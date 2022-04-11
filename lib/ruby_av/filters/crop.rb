module RubyAv
  module Filters
    # filter to crop video
    # see full documentation on http://ffmpeg.org/ffmpeg-filters.html#crop
    class Crop < Hash
      attr_reader :encoder

      # @param encoder [Encoder]
      # @param opts [Hash] ex: { width: "400", height: "400", x: "100", y: "323" }
      def initialize(encoder, opts)
        @encoder = encoder
        super(nil)

        merge!(opts)
      end

      # Example
      # {include:file:examples/crop.rb}
      #
      # @return [Array] Array of Encoder#other_options
      def run
        encoder.add_option "-filter:v", "crop=#{self[:width]}:#{self[:height]}:#{self[:x]}:#{self[:y]}"
        encoder.add_option "-c:a", "copy"
      end
    end
  end
end
