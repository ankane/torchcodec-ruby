module TorchCodec
  module Decoders
    class VideoDecoder
      attr_reader :metadata

      def initialize(
        source,
        stream_index: nil,
        dimension_order: "NCHW",
        num_ffmpeg_threads: 1,
        device: nil,
        seek_mode: "exact",
        transforms: nil,
        custom_frame_mappings: nil
      )
        allowed_seek_modes = ["exact", "approximate"]
        if !allowed_seek_modes.include?(seek_mode)
          raise ArgumentError, "Invalid seek mode (#{seek_mode})."
        end

        # Validate seek_mode and custom_frame_mappings are not mismatched
        if !custom_frame_mappings.nil? && seek_mode == "approximate"
          raise ArgumentError,
            "custom_frame_mappings is incompatible with seek_mode: 'approximate'. " +
            "Use seek_mode: 'custom_frame_mappings' or leave it unspecified to automatically use custom frame mappings."
        end

        # Auto-select custom_frame_mappings seek_mode and process data when mappings are provided
        custom_frame_mappings_data = nil
        if !custom_frame_mappings.nil?
          raise Todo
        end

        @decoder = Decoders.create_decoder(source, seek_mode)

        (
          @metadata,
          @stream_index,
          @begin_stream_seconds,
          @end_stream_seconds,
          @num_frames
        ) = _get_and_validate_stream_metadata(
          decoder: @decoder, stream_index: stream_index
        )

        allowed_dimension_orders = ["NCHW", "NHWC"]
        if !allowed_dimension_orders.include?(dimension_order)
          raise ArgumentError, "Invalid dimension order (#{dimension_order})."
        end

        if num_ffmpeg_threads.nil?
          raise ArgumentError, "#{num_ffmpeg_threads} should be an int."
        end

        if device.nil?
          device = "cpu" # TODO Torch.get_default_device.to_s
        elsif device.is_a?(Torch::Device)
          device = device.to_s
        end

        device_variant = Decoders._get_cuda_backend
        transform_specs = Transforms._make_transform_specs(
          transforms,
          [@metadata[:height], @metadata[:width]]
        )

        Core.add_video_stream(
          @decoder,
          num_ffmpeg_threads,
          dimension_order,
          @stream_index,
          device,
          device_variant,
          transform_specs,
          custom_frame_mappings_data
        )
      end

      def get_frame_at(index)
        data, pts_seconds, duration_seconds = Core.get_frame_at_index(@decoder, index)
        {
          data: data,
          pts_seconds: pts_seconds.item,
          duration_seconds: duration_seconds.item
        }
      end

      def get_frames_at(indices)
        data, pts_seconds, duration_seconds = Core.get_frames_at_indices(@decoder, indices)

        {
          data: data,
          pts_seconds: pts_seconds,
          duration_seconds: duration_seconds
        }
      end

      def get_frames_in_range(start, stop, step: 1)
        frames = Core.get_frames_in_range(
          @decoder,
          start,
          stop,
          step
        )
        {
          data: frames[0],
          pts_seconds: frames[1],
          duration_seconds: frames[2]
        }
      end

      def get_frame_played_at(seconds)
        if !(@begin_stream_seconds <= seconds && seconds < @end_stream_seconds)
          raise IndexError, "Invalid pts in seconds: #{seconds}."
        end
        data, pts_seconds, duration_seconds = Core.get_frame_at_pts(
          @decoder, seconds
        )
        {
          data: data,
          pts_seconds: pts_seconds.item,
          duration_seconds: duration_seconds.item
        }
      end

      private

      def _get_and_validate_stream_metadata(
        decoder:,
        stream_index: nil
      )
        container_metadata = Core.get_container_metadata(decoder)

        if stream_index.nil?
          if (stream_index = container_metadata[:best_video_stream_index]).nil?
            raise ArgumentError, "The best video stream is unknown and there is no specified stream."
          end
        end

        if stream_index >= container_metadata[:streams].length
          raise ArgumentError, "The stream index #{stream_index} is not a valid stream."
        end

        metadata = container_metadata[:streams][stream_index]
        if !metadata.key?(:begin_stream_seconds_from_content)
          raise ArgumentError, "The stream at index #{stream_index} is not a video stream."
        end

        if metadata[:begin_stream_seconds].nil?
          raise ArgumentError, "The minimum pts value in seconds is unknown."
        end
        begin_stream_seconds = metadata[:begin_stream_seconds]

        if metadata[:end_stream_seconds].nil?
          raise ArgumentError, "The maximum pts value in seconds is unknown."
        end
        end_stream_seconds = metadata[:end_stream_seconds]

        if metadata[:num_frames].nil?
          raise ArgumentError, "The number of frames is unknown."
        end
        num_frames = metadata[:num_frames]

        [
          metadata,
          stream_index,
          begin_stream_seconds,
          end_stream_seconds,
          num_frames
        ]
      end
    end
  end
end
