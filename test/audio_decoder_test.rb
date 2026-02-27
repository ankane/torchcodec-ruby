require_relative "test_helper"

class AudioDecoderTest < Minitest::Test
  def test_metadata
    decoder = TorchCodec::Decoders::AudioDecoder.new("test/support/nasa_13013.mp4.audio.mp3")
    metadata = decoder.metadata
    assert_equal 8000, metadata[:sample_rate]
    assert_equal 2, metadata[:num_channels]
  end

  def test_get_all_samples
    decoder = TorchCodec::Decoders::AudioDecoder.new("test/support/nasa_13013.mp4.audio.mp3")
    samples = decoder.get_all_samples
    assert_equal [2, 104448], samples[:data].size
    assert_in_delta 0.138125, samples[:pts_seconds]
    assert_in_delta 13.056, samples[:duration_seconds]
    assert_equal 8000, samples[:sample_rate]
  end
end
