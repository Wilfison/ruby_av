require "open3"

module RubyAv
  # Class that executes FFMPEG commands
  class Transcoder
    attr_reader :command, :output_file, :validate

    @@timeout = 30

    class << self
      attr_accessor :timeout
    end

    def initialize(output_file, raw_options, validate: false)
      @output_file = output_file
      @command = [RubyAv.ffmpeg_binary, "-v", "error", "-y", *raw_options.to_a, output_file]
      @validate = validate
      @errors = []
    end

    # run commands {|pregress| ... }
    # @yield [Number] return a transcoder progress
    def run(&block)
      transcode_media(&block)

      if validate
        validate_output_file(&block)

        encoded
      end

      nil
    end

    # @return [Media] Encoded output file
    def encoded
      @encoded ||= Media.new(output_file) if File.exist?(output_file)
    end

    def encoding_succeeded?
      @errors.empty?
    end

    def timeout
      self.class.timeout
    end

    private

    # rubocop:disable Metrics/CyclomaticComplexity, Metrics/AbcSize, Metrics/PerceivedComplexity
    def transcode_media
      RubyAv.logger.info("Running transcoding...\n#{command.join(" ")}\n")
      @output = ""

      Open3.popen3(*command) do |_stdin, _stdout, stderr, wait_thr|
        yield(0.0) if block_given?

        next_line = proc do |line|
          fix_encoding(line)

          @output << line

          if line.include?("time=")
            time = if line =~ /time=(\d+):(\d+):(\d+.\d+)/ # ffmpeg 0.8 and above style
                     (Regexp.last_match(1).to_i * 3600) + (Regexp.last_match(2).to_i * 60) + Regexp.last_match(3).to_f
                   else # better make sure it wont blow up in case of unexpected output
                     0.0
                   end

            if @movie
              progress = time / @movie.duration

              yield(progress) if block_given?
            end
          end
        end

        if timeout
          stderr.each_with_timeout(wait_thr.pid, timeout, "size=", &next_line)
        else
          stderr.each("size=", &next_line)
        end

        @errors << "ffmpeg returned non-zero exit code" unless wait_thr.value.success?

      rescue Timeout::Error
        RubyAv.logger.error "Process hung...\n@command\n#{command}\nOutput\n#{@output}\n"

        raise Error, "Process hung. Full output: #{@output}"
      end
    end
    # rubocop:enable Metrics/CyclomaticComplexity, Metrics/AbcSize, Metrics/PerceivedComplexity

    def fix_encoding(output)
      output[/test/]
    rescue ArgumentError
      output.force_encoding("ISO-8859-1")
    end

    def add_invalid_erros
      @errors << "no output file created" unless File.exist?(@output_file)
      @errors << "encoded file is invalid" if encoded.nil? || !encoded.valid?
    end

    def validate_output_file
      add_invalid_erros

      if encoding_succeeded?
        yield(1.0) if block_given?

        RubyAv.logger.info "Transcoding to #{@output_file} succeeded\n"
      else
        errors = "Errors: #{@errors.join(", ")}. "
        RubyAv.logger.error "Failed encoding...\n#{command}\n\n#{@output}\n#{errors}\n"

        raise Error, "Failed encoding.#{errors}Full output: #{@output}"
      end
    end
  end
end
