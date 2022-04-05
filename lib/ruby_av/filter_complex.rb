module RubyAv
  module FilterConplex
    # filter complex to concat entries
    #
    # @return [String] from -filter_complex
    def concat(_opts)
      filter_map = ""
      has_video_stream = false
      has_audio_stream = false

      inputs.each_with_index do |inp, index|
        unless inp.media.video_codec.nil?
          filter_map += "[#{index}:v]"
          has_video_stream = true
        end

        if inp.media.audio_streams.any?
          filter_map += "[#{index}:a]"
          has_audio_stream = true
        end
      end

      filter_map += "concat=n=#{inputs.size}"
      filter_map += ":v=1" if has_video_stream
      filter_map += ":a=1" if has_audio_stream

      @maps = []

      if has_video_stream
        filter_map += "[outv]"
        maps << "[outv]"
      end

      if has_audio_stream
        filter_map += "[outa]"
        maps << "[outa]"
      end

      add_filter_complex(filter_map)
    end
  end
end
