#!/usr/bin/env ruby
# frozen_string_literal: true

output_path = "#{Dir.pwd}/tmp"
output_file = "#{output_path}/outputs/with_sound_output.mp4"

# Trim a video file
RubyAv::Encoder.run(output_file) do |enc|
  # add the video file
  enc.add_input("#{output_path}/input.mp4")

  # add the audio file
  enc.add_input("#{output_path}/track1.mp3")

  # -af apad: we are applying the apad filter,
  # which pads the end of an audio stream with silence.
  enc.add_option "-af", "apad"

  # Used together with -shortest to trim/extend audio streams
  # to the same length as the video stream.
  enc.add_option "-shortest"

  # run the command in ffmpeg
  # and validate if the output file was generated
  enc.transcode(validate: true)
end
