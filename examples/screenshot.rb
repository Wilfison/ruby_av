require_relative "../lib/ruby_av"

current_path = Dir.pwd
media = RubyAv::Media.new("#{current_path}/tmp/input.mp4")

# capture 1 frame on 3s
# seek_time = HH:MM:SS.MILLISECONDS
media.screenshot("#{current_path}/tmp/output.png", frames: 1, seek_time: "00:00:03")

# with custom resolution
opts1 = { resolution: "480x640", frames: 1, seek_time: "00:00:03" }
media.screenshot("#{current_path}/tmp/output_#{opts1[:resolution]}.png", opts1)
