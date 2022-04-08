#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "../lib/ruby_av"

output_path = "#{Dir.pwd}/tmp"
output_file = "#{output_path}/croped_output.mp4"

RubyAv::Encoder.run(output_file) do |enc|
  enc.add_input("#{output_path}/input.mp4")

  # time format: HH:MM:SS.MILLISECONDS
  enc.add_filter_complex :trim, start: "00:00:00", end: "00:00:05"

  enc.transcode(validate: true)
end
