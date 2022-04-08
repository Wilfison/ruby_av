#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "../lib/ruby_av"

output_path = "#{Dir.pwd}/tmp"

# read more about Scaling
# https://trac.ffmpeg.org/wiki/Scaling

# Simple Rescaling
RubyAv::Encoder.run("#{output_path}/output_hd.mp4") do |enc|
  # add the input file
  enc.add_input("#{output_path}/input.mp4")

  # set video filter scale
  enc.add_option "-vf", "scale=720:1080,setsar=1:1"

  # run the command in ffmpeg
  # and validate if the output file was generated
  enc.transcode(validate: true)
end

# Keeping the Aspect Ratio
RubyAv::Encoder.run("#{output_path}/output_sd.mp4") do |enc|
  # add the input file
  enc.add_input("#{output_path}/input.mp4")

  # If we'd like to keep the aspect ratio, we need to specify only one component,
  # either width or height, and set the other component to -1.
  enc.add_option "-vf", "scale=640:-1"

  # run the command in ffmpeg
  # and validate if the output file was generated
  enc.transcode(validate: true)
end
