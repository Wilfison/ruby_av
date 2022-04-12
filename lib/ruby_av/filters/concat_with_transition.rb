module RubyAv
  module Filters
    # Filter complex to concat entries and add transistions
    class ConcatWithTransition
      attr_reader :encoder, :opts

      # @param encoder [Encoder]
      # @param opts [Hash] Hash with { transition, offset, duration }
      def initialize(encoder, opts = {})
        @encoder = encoder
        @opts = opts
      end

      # Example
      # {include:file:examples/concat_with_transition.rb}
      #
      # @return [String] from -filter_complex
      def run
        filter_map = "xfade=transition=#{transition}:duration=#{duration}:offset=#{offset},format=yuv420p"

        encoder.add_filter_complex(filter_map)
      end

      # Transition Effect Name
      # @return [String]
      def transition
        return opts[:transition] if RubyAv::Helpers::XFADE_TRANSITIONS.include? opts[:transition].to_s
        return RubyAv::Helpers::XFADE_TRANSITIONS.sample if opts[:transition].to_s == "random"

        "fade"
      end

      # Time before transiction
      # @return [String]
      def offset
        opts[:offset] || "5"
      end

      # Transition Effect Duration
      # @return [String]
      def duration
        opts[:duration] || "0.5"
      end
    end
  end
end
