module TorchCodec
  module Encoders
    class VideoEncoder
      def initialize(frames, frame_rate:)
        if !frames.is_a?(Torch::Tensor)
          raise ArgumentError, "Expected frames to be a Tensor, got #{frames.class.name}."
        end
        if frames.ndim != 4
          raise ArgumentError, "Expected 4D frames, got #{frames.shape}."
        end
        if frames.dtype != Torch.uint8
          raise ArgumentError, "Expected uint8 frames, got #{frames.dtype}."
        end
        if frame_rate <= 0
          raise ArgumentError, "#{frame_rate} must be > 0."
        end

        @frames = frames
        @frame_rate = frame_rate
      end
    end
  end
end
