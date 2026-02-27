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
end
