output_path = "#{Dir.pwd}/tmp"
output_file = "#{output_path}/outputs/output_croped.mp4"

# Crop a video file
RubyAv::Encoder.run(output_file) do |enc|
  # add the input file
  enc.add_input("#{output_path}/input.mp4")

  # add crop filter and set options
  # To crop a 400×400 section, starting from position (x: 160, y: 323)
  enc.add_filter_complex :crop, width: "400", height: "400", x: "100", y: "323"

  # run the command in ffmpeg
  # and validate if the output file was generated
  enc.transcode(validate: true)
end
