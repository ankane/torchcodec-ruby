require_relative "test_helper"

class VideoDecoderTest < Minitest::Test
  def test_metadata
    decoder = TorchCodec::Decoders::VideoDecoder.new("test/support/nasa_13013.mp4")
    metadata = decoder.metadata
    assert_in_delta 0, metadata[:begin_stream_seconds_from_content]
    assert_in_delta 13.013, metadata[:end_stream_seconds_from_content]
    assert_in_delta 13.013, metadata[:end_stream_seconds]
    assert_equal 390, metadata[:num_frames]
    assert_in_delta 29.97003, metadata[:average_fps]
    assert_equal 480, metadata[:width]
    assert_equal 270, metadata[:height]
    assert_equal 390, metadata[:num_frames_from_header]
    assert_equal 390, metadata[:num_frames_from_content]
    assert_in_delta 29.97003, metadata[:average_fps_from_header]
    assert_equal Rational(1, 1), metadata[:pixel_aspect_ratio]
    assert_in_delta 13.013, metadata[:duration_seconds_from_header]
    assert_in_delta 13.013, metadata[:duration_seconds]
    assert_in_delta 128783.0, metadata[:bit_rate]
    assert_in_delta 0.0, metadata[:begin_stream_seconds_from_header]
    assert_in_delta 0.0, metadata[:begin_stream_seconds]
    assert_equal "h264", metadata[:codec]
    assert_equal 3, metadata[:stream_index]
  end

  def test_get_frame_at
    decoder = TorchCodec::Decoders::VideoDecoder.new("test/support/nasa_13013.mp4")
    frame = decoder.get_frame_at(0)
    assert_equal [3, 270, 480], frame[:data].shape
    assert_in_delta 0.0, frame[:pts_seconds]
    assert_in_delta 0.03336666666666667, frame[:duration_seconds]
  end

  def test_get_frames_at
    decoder = TorchCodec::Decoders::VideoDecoder.new("test/support/nasa_13013.mp4")
    frames = decoder.get_frames_at(Torch.tensor([0, 1]))
    assert_equal [2, 3, 270, 480], frames[:data].shape
    assert_equal [2], frames[:pts_seconds].shape
    assert_equal [2], frames[:duration_seconds].shape
  end

  def test_get_frames_in_range
    decoder = TorchCodec::Decoders::VideoDecoder.new("test/support/nasa_13013.mp4")
    frames = decoder.get_frames_in_range(0, 10, step: 3)
    assert_equal [4, 3, 270, 480], frames[:data].shape
    assert_equal [4], frames[:pts_seconds].shape
    assert_equal [4], frames[:duration_seconds].shape
  end

  def test_get_frame_played_at
    decoder = TorchCodec::Decoders::VideoDecoder.new("test/support/nasa_13013.mp4")
    frame = decoder.get_frame_played_at(0)
    assert_equal [3, 270, 480], frame[:data].shape
    assert_in_delta 0.0, frame[:pts_seconds]
    assert_in_delta 0.03336666666666667, frame[:duration_seconds]
  end
end
