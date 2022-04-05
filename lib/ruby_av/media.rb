require "time"
require "open3"
require "multi_json"
require "uri"
require "net/http"

module RubyAv
  class Media
    attr_reader :path, :duration, :time, :bitrate, :rotation, :creation_time, :video_stream, :video_codec,
                :video_bitrate, :colorspace, :width, :height, :sar, :dar, :frame_rate, :audio_streams,
                :audio_stream, :audio_codec, :audio_bitrate, :audio_sample_rate, :audio_channels, :audio_tags,
                :container, :metadata, :format_tags

    UNSUPPORTED_CODEC_PATTERN = /^Unsupported codec with id (\d+) for input stream (\d+)$/.freeze

    def initialize(path)
      @path = path

      if remote?
        @head = head
        unless @head.is_a?(Net::HTTPSuccess)
          raise Error, "the URL '#{path}' does not exist or is not available (response code: #{@head.code})"
        end
      else
        raise Error, "the file '#{path}' does not exist" unless File.exist?(path)
      end

      @path = path

      # ffmpeg will output to stderr
      command = [RubyAv.ffprobe_binary, "-i", path, "-print_format", "json", "-show_format", "-show_streams",
                 "-show_error"]
      std_output = ""
      std_error = ""

      Open3.popen3(*command) do |_stdin, stdout, stderr|
        std_output = stdout.read unless stdout.nil?
        std_error = stderr.read unless stderr.nil?
      end

      fix_encoding(std_output)
      fix_encoding(std_error)

      begin
        @metadata = MultiJson.load(std_output, symbolize_keys: true)
      rescue MultiJson::ParseError
        raise "Could not parse output from FFProbe:\n#{std_output}"
      end

      if @metadata.key?(:error)

        @duration = 0

      else
        video_streams = @metadata[:streams].select do |stream|
          stream.key?(:codec_type) and stream[:codec_type] == "video"
        end
        audio_streams = @metadata[:streams].select do |stream|
          stream.key?(:codec_type) and stream[:codec_type] == "audio"
        end

        @container = @metadata[:format][:format_name]

        @duration = @metadata[:format][:duration].to_f

        @time = @metadata[:format][:start_time].to_f

        @format_tags = @metadata[:format][:tags]

        @creation_time = if @format_tags&.key?(:creation_time)
                           begin
                             Time.parse(@format_tags[:creation_time])
                           rescue ArgumentError
                             nil
                           end
                         end

        @bitrate = @metadata[:format][:bit_rate].to_i

        # TODO: Handle multiple video codecs (is that possible?)
        video_stream = video_streams.first
        unless video_stream.nil?
          @video_codec = video_stream[:codec_name]
          @colorspace = video_stream[:pix_fmt]
          @width = video_stream[:width]
          @height = video_stream[:height]
          @video_bitrate = video_stream[:bit_rate].to_i
          @sar = video_stream[:sample_aspect_ratio]
          @dar = video_stream[:display_aspect_ratio]

          @frame_rate = (Rational(video_stream[:avg_frame_rate]) unless video_stream[:avg_frame_rate] == "0/0")

          @video_stream = "#{video_stream[:codec_name]} (#{video_stream[:profile]}) (#{video_stream[:codec_tag_string]} / #{video_stream[:codec_tag]}), #{colorspace}, #{resolution} [SAR #{sar} DAR #{dar}]"

          @rotation = if video_stream.key?(:tags) && video_stream[:tags].key?(:rotate)
                        video_stream[:tags][:rotate].to_i
                      end
        end

        @audio_streams = audio_streams.map do |stream|
          {
            index: stream[:index],
            channels: stream[:channels].to_i,
            codec_name: stream[:codec_name],
            sample_rate: stream[:sample_rate].to_i,
            bitrate: stream[:bit_rate].to_i,
            channel_layout: stream[:channel_layout],
            tags: stream[:streams],
            overview: "#{stream[:codec_name]} (#{stream[:codec_tag_string]} / #{stream[:codec_tag]}), #{stream[:sample_rate]}Hz, #{stream[:channel_layout]}, #{stream[:sample_fmt]}, #{stream[:bit_rate]} bit/s"
          }
        end

        audio_stream = @audio_streams.first
        unless audio_stream.nil?
          @audio_channels = audio_stream[:channels]
          @audio_codec = audio_stream[:codec_name]
          @audio_sample_rate = audio_stream[:sample_rate]
          @audio_bitrate = audio_stream[:bitrate]
          @audio_channel_layout = audio_stream[:channel_layout]
          @audio_tags = audio_stream[:audio_tags]
          @audio_stream = audio_stream[:overview]
        end

      end

      unsupported_stream_ids = unsupported_streams(std_error)
      nil_or_unsupported = ->(stream) { stream.nil? || unsupported_stream_ids.include?(stream[:index]) }

      @invalid = true if nil_or_unsupported.call(video_stream) && nil_or_unsupported.call(audio_stream)
      @invalid = true if @metadata.key?(:error)
      @invalid = true if std_error.include?("could not find codec parameters")
    end

    def unsupported_streams(std_error)
      [].tap do |stream_indices|
        std_error.each_line do |line|
          match = line.match(UNSUPPORTED_CODEC_PATTERN)
          stream_indices << match[2].to_i if match
        end
      end
    end

    def valid?
      !@invalid
    end

    def remote?
      @path =~ URI::DEFAULT_PARSER.make_regexp(%w[http https])
    end

    def local?
      !remote?
    end

    def width
      rotation.nil? || rotation == 180 ? @width : @height
    end

    def height
      rotation.nil? || rotation == 180 ? @height : @width
    end

    def resolution
      "#{width}x#{height}" unless width.nil? || height.nil?
    end

    def calculated_aspect_ratio
      aspect_from_dar || aspect_from_dimensions
    end

    def calculated_pixel_aspect_ratio
      aspect_from_sar || 1
    end

    def size
      if local?
        File.size(@path)
      else
        @head.content_length
      end
    end

    # Capture screenshot from media
    #
    # @param output_file [String] path to screenshot output
    # @param options [Hash] with seek_time and frames options
    def screenshot(output_file, options = {}, validate: true, &block)
      opts = EncodingOptions.new({ screenshot: true, seek_time: "00:00:01", frames: 1 }.merge!(options))
      raw_options = ["-i", path, *opts.to_a]

      Transcoder.new(output_file, raw_options, validate: validate).run(&block)
    end

    protected

    def aspect_from_dar
      calculate_aspect(dar)
    end

    def aspect_from_sar
      calculate_aspect(sar)
    end

    def calculate_aspect(ratio)
      return nil unless ratio

      w, h = ratio.split(":")
      return nil if w == "0" || h == "0"

      @rotation.nil? || (@rotation == 180) ? (w.to_f / h.to_f) : (h.to_f / w.to_f)
    end

    def aspect_from_dimensions
      aspect = width.to_f / height.to_f

      aspect.nan? ? nil : aspect
    end

    def fix_encoding(output)
      output[/test/] # Running a regexp on the string throws error if it's not UTF-8
    rescue ArgumentError
      output.force_encoding("ISO-8859-1")
    end

    def head(location = @path, limit = RubyAv.max_http_redirect_attempts)
      url = URI(location)
      return unless url.path

      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = url.port == 443
      response = http.request_head(url.request_uri)

      case response
      when Net::HTTPRedirection
        raise RubyAv::HTTPTooManyRequests if limit.zero?

        new_uri = url + URI(response["Location"])

        head(new_uri, limit - 1)
      else
        response
      end
    rescue SocketError, Errno::ECONNREFUSED => e
      nil
    end
  end
end
