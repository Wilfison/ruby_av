output_path = "#{Dir.pwd}/tmp"
output_file = "#{output_path}/outputs/trimmed_output.mp4"

# Trim a video file
RubyAv::Encoder.run(output_file) do |enc|
  # add the input file
  enc.add_input("#{output_path}/input.mp4")

  # add trim filter and set start and end time
  # time format: HH:MM:SS.MILLISECONDS
  enc.add_filter_complex :trim, start: "00:00:00", end: "00:00:05"

  # run the command in ffmpeg
  # and validate if the output file was generated
  enc.transcode(validate: true)
end
