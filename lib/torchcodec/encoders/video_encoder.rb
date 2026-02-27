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

      def to_file(
        dest,
        codec: nil,
        pixel_format: nil,
        crf: nil,
        preset: nil,
        extra_options: nil
      )
        preset = preset.is_a?(Integer) ? preset.to_s : preset
        Core.encode_video_to_file(
          @frames,
          @frame_rate,
          dest.to_s,
          codec,
          pixel_format,
          crf,
          preset,
          extra_options
        )
      end
    end
  end
end
