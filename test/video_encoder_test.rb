require_relative "test_helper"

class VideoEncoderTest < Minitest::Test
  def test_works
    frames = Torch.zeros(60, 3, 1080, 1920, dtype: :uint8)
    frame_rate = 24
    _encoder = TorchCodec::Encoders::VideoEncoder.new(frames, frame_rate: frame_rate)
  end
end
