require_relative "../lib/ruby_av"

current_path = Dir.pwd
output_file = "#{current_path}/tmp/output.mp4"

RubyAv::Encoder.run(output_file) do |enc|
  enc.add_input("#{current_path}/tmp/input.mp4")
  enc.add_input("#{current_path}/tmp/input.mp4")

  enc.add_filter_complex :concat

  enc.transcode(validate: true)
end
