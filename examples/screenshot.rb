output_path = "#{Dir.pwd}/tmp"
media = RubyAv::Media.new("#{output_path}/input.mp4")

# capture first frame
media.screenshot("#{output_path}/outputs/output.png")

# capture 1 frame on 3s
# seek_time = HH:MM:SS.MILLISECONDS
media.screenshot("#{output_path}/outputs/output_3s.png", seek_time: "00:00:03")

# capture 1 frame on 5s
# with custom resolution
media.screenshot("#{output_path}/outputs/output_5s.png", resolution: "480x640", seek_time: 5)

# Screenshot/Thumbnail every 10 seconds
# read more about in this post
# @see https://trac.ffmpeg.org/wiki/Create%20a%20thumbnail%20image%20every%20X%20seconds%20of%20the%20video
media.screenshot("#{output_path}/outputs/thumbnail%03d.jpg", vf: "fps=1/10")
