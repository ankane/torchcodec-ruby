require_relative "test_helper"

class AudioEncoderTest < Minitest::Test
  def test_to_tensor
    samples = Torch.zeros(8000)
    sample_rate = 8000
    encoder = TorchCodec::Encoders::AudioEncoder.new(samples, sample_rate: sample_rate)
    tensor = encoder.to_tensor("mp3")
    assert_equal [1413], tensor.shape
    assert_equal [73, 68, 51], tensor[..2].to_a
  end
end
