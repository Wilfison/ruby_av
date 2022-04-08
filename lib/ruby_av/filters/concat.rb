module RubyAv
  module Filters
    # filter complex to concat entries
    class Concat
      attr_reader :encoder

      def initialize(encoder, _opts = {})
        @encoder = encoder
      end

      # @return [String] from -filter_complex
      def run
        filter_map = ""
        has_video_stream = false
        has_audio_stream = false

        encoder.inputs.each_with_index do |inp, index|
          unless inp.media.video_codec.nil?
            filter_map += "[#{index}:v]"
            has_video_stream = true
          end

          if inp.media.audio_streams.any?
            filter_map += "[#{index}:a]"
            has_audio_stream = true
          end
        end

        filter_map += "concat=n=#{encoder.inputs.size}"
        filter_map += ":v=1" if has_video_stream
        filter_map += ":a=1" if has_audio_stream

        encoder.maps = []

        if has_video_stream
          filter_map += "[outv]"
          encoder.maps << "[outv]"
        end

        if has_audio_stream
          filter_map += "[outa]"
          encoder.maps << "[outa]"
        end

        encoder.add_filter_complex(filter_map)
      end
    end
  end
end
