# RubyAv - Wrapper for FFMPEG

## Simple way to use FFMPEG on ruby


Based on [Streamio FFMPEG](https://github.com/streamio/streamio-ffmpeg)


---------------

### Work in progress...

---------------

### Reading Media Metadata

```ruby
media = RubyAv::Media.new("path/to/media.mov")

media.duration # 7.5 (duration of the media in seconds)
media.bitrate # 481 (bitrate in kb/s)
media.size # 455546 (filesize in bytes)

media.video_stream # "h264, yuv420p, 640x480 [PAR 1:1 DAR 4:3], 371 kb/s, 16.75 fps, 15 tbr, 600 tbn, 1200 tbc" (raw video stream info)
media.video_codec # "h264"
media.colorspace # "yuv420p"
media.resolution # "640x480"
media.width # 640 (width of the media in pixels)
media.height # 480 (height of the media in pixels)
media.frame_rate # 16.72 (frames per second)

media.audio_stream # "aac, 44100 Hz, stereo, s16, 75 kb/s" (raw audio stream info)
media.audio_codec # "aac"
media.audio_sample_rate # 44100
media.audio_channels # 2

# Multiple audio streams
media.audio_streams[0] # "aac, 44100 Hz, stereo, s16, 75 kb/s" (raw audio stream info)

media.valid? # true (would be false if ffmpeg fails to read the media)
```

### Transcoding

See the [examples section](https://github.com/Wilfison/ruby_av/tree/main/examples) to see what the gem is already capable of

-------------

**Change scale keeping the Aspect Ratio**
```ruby
RubyAv::Encoder.run("path/to/output.mp4") do |enc|
  enc.add_input("path/to/input.mp4") # add the input file

  enc.add_option "-vf", "scale=640:-1" # set the ffmpeg scale filter

  enc.transcode # run the command in ffmpeg
end
```

-------------

**Concatenate videos**
```ruby
RubyAv::Encoder.run("path/to/output.mp4") do |enc|
  enc.add_input("path/to/input1.mp4") # add the first input file
  enc.add_input("path/to/input2.mp4") # add the second input file

  # apply the concatenate effect
  enc.add_filter_complex :concat

  # run the command in ffmpeg
  # and validate if the output file was generated
  enc.transcode(validate: true)
end
```

-------------

**Taking screenshots**
```ruby
media = RubyAv::Media.new("path/to/input.mp4")

# capture first frame
media.screenshot("#{output_path}/output.png")

# capture 1 frame on 3s
# seek_time can be HH:MM:SS.MILLISECONDS
media.screenshot("path/to/output.png", seek_time: 3)

# capture 1 frame on 5s
# with custom resolution
media.screenshot("path/to/output.png", resolution: "480x640", seek_time: 5)
```

### Copyright
See [LICENSE](https://github.com/Wilfison/ruby_av/blob/main/LICENSE.txt) for details.
