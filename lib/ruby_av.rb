# frozen_string_literal: true

$LOAD_PATH.unshift File.dirname(__FILE__)

require "logger"
require "stringio"
require "pry"

require "ruby_av/version"
require "ruby_av/media"
require "ruby_av/filter_complex"
require "ruby_av/transcoder"
require "ruby_av/input"
require "ruby_av/encoder"
require "ruby_av/encoding_options"

# Wrapper for FFMPEG
#
# @author Wilfison Batista
#
# @see https://github.com/Wilfison/ruby_av
module RubyAv
  class Error < StandardError; end
  class HTTPTooManyRequests < StandardError; end

  # RubyAv logs information about its progress when it's transcoding.
  # Jack in your own logger through this method if you wish to.
  #
  # @param [Logger] log your own logger
  # @return [Logger] the logger you set
  def self.logger=(log)
    @logger = log
  end

  # Get RubyAv logger.
  #
  # @return [Logger]
  def self.logger
    return @logger if @logger

    logger = Logger.new($stdout)
    logger.level = Logger::INFO
    @logger = logger
  end

  # Set the path of the ffmpeg binary.
  # Can be useful if you need to specify a path such as /usr/local/bin/ffmpeg
  #
  # @param [String] path to the ffmpeg binary
  # @return [String] the path you set
  # @raise Error if the ffmpeg binary cannot be found
  def self.ffmpeg_binary=(bin)
    raise Error, "the ffmpeg binary, \'#{bin}\', is not executable" if bin.is_a?(String) && !File.executable?(bin)

    @ffmpeg_binary = bin
  end

  # Get the path to the ffmpeg binary, defaulting to 'ffmpeg'
  #
  # @return [String] the path to the ffmpeg binary
  # @raise Error if the ffmpeg binary cannot be found
  def self.ffmpeg_binary
    @ffmpeg_binary || which("ffmpeg")
  end

  # Get the path to the ffprobe binary, defaulting to what is on ENV['PATH']
  #
  # @return [String] the path to the ffprobe binary
  # @raise Error if the ffprobe binary cannot be found
  def self.ffprobe_binary
    @ffprobe_binary || which("ffprobe")
  end

  # Set the path of the ffprobe binary.
  # Can be useful if you need to specify a path such as /usr/local/bin/ffprobe
  #
  # @param [String] path to the ffprobe binary
  # @return [String] the path you set
  # @raise Error if the ffprobe binary cannot be found
  def self.ffprobe_binary=(bin)
    raise Error, "the ffprobe binary, \'#{bin}\', is not executable" if bin.is_a?(String) && !File.executable?(bin)

    @ffprobe_binary = bin
  end

  # Get the maximum number of http redirect attempts
  #
  # @return [Integer] the maximum number of retries
  def self.max_http_redirect_attempts
    @max_http_redirect_attempts.nil? ? 10 : @max_http_redirect_attempts
  end

  # Set the maximum number of http redirect attempts.
  #
  # @param value [Integer] the maximum number of retries
  # @return [Integer] the number of retries you set
  # @raise Error if the value is negative or not an Integer
  def self.max_http_redirect_attempts=(value)
    raise Error, "max_http_redirect_attempts must be an integer" if value && !value.is_a?(Integer)
    raise Error, "max_http_redirect_attempts may not be negative" if value&.negative?

    @max_http_redirect_attempts = value
  end

  # Cross-platform way of finding an executable in the $PATH.
  #
  # which('ruby') #=> /usr/bin/ruby
  # see: http://stackoverflow.com/questions/2108727/which-in-ruby-checking-if-program-exists-in-path-from-ruby
  def self.which(cmd)
    exts = ENV["PATHEXT"] ? ENV["PATHEXT"].split(";") : [""]

    ENV["PATH"].split(File::PATH_SEPARATOR).each do |path|
      exts.each do |ext|
        exe = File.join(path, "#{cmd}#{ext}")

        return exe if File.executable? exe
      end
    end

    raise Error, "the #{cmd} binary could not be found in #{ENV["PATH"]}"
  end
end
