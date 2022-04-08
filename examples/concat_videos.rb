#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "../lib/ruby_av"

output_path = "#{Dir.pwd}/tmp"
output_file = "#{output_path}/output_concated.mp4"

# starts a new encoder instance with the output file name
RubyAv::Encoder.run(output_file) do |enc|
  # add the first input file
  enc.add_input("#{output_path}/input.mp4")
  # add the second input file
  enc.add_input("#{output_path}/input.mp4")

  # apply the concatenate effect
  enc.add_filter_complex :concat

  # run the command in ffmpeg
  # and validate if the output file was generated
  enc.transcode(validate: true)
end
