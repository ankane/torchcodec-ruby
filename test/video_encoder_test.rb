require_relative "test_helper"

class VideoEncoderTest < Minitest::Test
  def test_to_file
    frames = Torch.zeros(60, 3, 1080, 1920, dtype: :uint8)
    frame_rate = 24
    encoder = TorchCodec::Encoders::VideoEncoder.new(frames, frame_rate: frame_rate)
    assert_nil encoder.to_file("/tmp/test.mp4")
    assert File.exist?("/tmp/test.mp4")
  end
end
