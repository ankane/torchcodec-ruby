module TorchCodec
  module Encoders
    class AudioEncoder
      def initialize(samples, sample_rate:)
        # Some of these checks are also done in C++: it's OK, they're cheap, and
        # doing them here allows to surface them when the AudioEncoder is
        # instantiated, rather than later when the encoding methods are called.
        if !samples.is_a?(Torch::Tensor)
          raise ArgumentError, "Expected samples to be a Tensor, got #{samples.class.name}."
        end
        if samples.ndim == 1
          # make it 2D and assume 1 channel
          samples = Torch.unsqueeze(samples, 0)
        end
        if samples.ndim != 2
          raise ArgumentError, "Expected 1D or 2D samples, got #{samples.shape}."
        end
        if samples.dtype != Torch.float32
          raise ArgumentError, "Expected float32 samples, got #{samples.dtype}."
        end
        if sample_rate <= 0
          raise ArgumentError, "#{sample_rate} must be > 0."
        end

        @samples = samples
        @sample_rate = sample_rate
      end

      def to_file(
        dest,
        bit_rate: nil,
        num_channels: nil,
        sample_rate: nil
      )
        Core.encode_audio_to_file(
          @samples,
          @sample_rate,
          dest.to_s,
          bit_rate,
          num_channels,
          sample_rate
        )
      end

      def to_tensor(
        format,
        bit_rate: nil,
        num_channels: nil,
        sample_rate: nil
      )
        Core.encode_audio_to_tensor(
          @samples,
          @sample_rate,
          format,
          bit_rate,
          num_channels,
          sample_rate
        )
      end
    end
  end
end
