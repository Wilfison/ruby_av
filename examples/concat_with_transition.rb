output_path = "#{Dir.pwd}/tmp"
output_file = "#{output_path}/outputs/concat_with_transition.mp4"

# starts a new encoder instance with the output file name
RubyAv::Encoder.run(output_file) do |enc|
  # add the first input file
  enc.add_input("#{output_path}/input.mp4")
  # add the second input file
  enc.add_input("#{output_path}/input.mp4")

  # apply the concatenate with transition effect
  # transition: check https://trac.ffmpeg.org/wiki/Xfade
  # offset: Time before transiction
  # duration: Transition Effect Duration
  enc.add_filter_complex :concat_with_transition, transition: :random, offset: 5, duration: "0.5"

  # run the command in ffmpeg
  # and validate if the output file was generated
  enc.transcode(validate: true)
end
