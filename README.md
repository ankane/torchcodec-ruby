# TorchCodec Ruby

:fire: Media encoding and decoding for Torch.rb

[![Build Status](https://github.com/ankane/torchcodec-ruby/actions/workflows/build.yml/badge.svg)](https://github.com/ankane/torchcodec-ruby/actions)

## Installation

First, [install FFmpeg](#ffmpeg-installation). For Homebrew, use:

```sh
brew install ffmpeg
```

Add this line to your application’s Gemfile:

```ruby
gem "torchcodec"
```

## Getting Started

This library follows the [Python API](https://meta-pytorch.org/torchcodec/). Some functionality is missing at the moment. PRs welcome!

### Audio

Encoding

```ruby
encoder = TorchCodec::Encoders::AudioEncoder.new(samples, sample_rate: 8000)
encoder.to_file("file.mp3")
tensor = encoder.to_tensor("mp3")
```

Decoding

```ruby
decoder = TorchCodec::Decoders::AudioDecoder.new("file.mp3")
decoder.metadata
decoder.get_all_samples
decoder.get_samples_played_in_range(start_seconds: 0, stop_seconds: 1)
```

### Video

Encoding

```ruby
encoder = TorchCodec::Encoders::VideoEncoder.new(frames, frame_rate: 24)
encoder.to_file("file.mp4")
tensor = encoder.to_tensor("mp4")
```

Decoding

```ruby
decoder = TorchCodec::Decoders::VideoDecoder.new("file.mp4")
decoder.metadata
decoder.get_frame_at(0)
decoder.get_frames_at(Torch.tensor([0, 1, 2]))
decoder.get_frames_in_range(0, 10, step: 3)
decoder.get_frame_played_at(0)
decoder.get_frames_played_at(Torch.tensor([0, 1, 2], dtype: :float64))
decoder.get_frames_played_in_range(0, 10)
```

## FFmpeg Installation

### Linux

For Ubuntu, use:

```sh
sudo apt install libavcodec-dev libavdevice-dev libavfilter-dev libavutil-dev
```

### Mac

```sh
brew install ffmpeg
```

## History

View the [changelog](https://github.com/ankane/torchcodec-ruby/blob/master/CHANGELOG.md)

## Contributing

Everyone is encouraged to help improve this project. Here are a few ways you can help:

- [Report bugs](https://github.com/ankane/torchcodec-ruby/issues)
- Fix bugs and [submit pull requests](https://github.com/ankane/torchcodec-ruby/pulls)
- Write, clarify, or fix documentation
- Suggest or add new features

To get started with development:

```sh
git clone https://github.com/ankane/torchcodec-ruby.git
cd torchcodec-ruby
bundle install
bundle exec rake compile
bundle exec rake download:files
bundle exec rake test
```
