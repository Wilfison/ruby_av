require_relative "../lib/ruby_av"

current_path = Dir.pwd
media = RubyAv::Media.new("#{current_path}/tmp/input.mp4")

# capture 1 frame on 3s
# seek_time = HH:MM:SS.MILLISECONDS
media.screenshot("#{current_path}/tmp/output.png", seek_time: "00:00:03")

# with custom resolution
opts1 = { resolution: "480x640", seek_time: "00:00:05" }
media.screenshot("#{current_path}/tmp/output_#{opts1[:resolution]}.png", opts1)

# Screenshot/Thumbnail every 10 seconds
# read more about in this post
# https://trac.ffmpeg.org/wiki/Create%20a%20thumbnail%20image%20every%20X%20seconds%20of%20the%20video
opts2 = { seek_time: nil, frames: nil, screenshot: false, vf: "fps=1/10" }
media.screenshot("#{current_path}/tmp/thumbnail%03d.jpg", opts2, validate: false)
