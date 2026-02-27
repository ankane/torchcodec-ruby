module TorchCodec
  module Decoders
    class AudioDecoder
      attr_reader :metadata

      def initialize(
        source,
        stream_index: nil,
        sample_rate: nil,
        num_channels: nil
      )
        @decoder = Decoders.create_decoder(source, "approximate")

        container_metadata = Core.get_container_metadata(@decoder)
        @stream_index =
          stream_index.nil? ? container_metadata[:best_audio_stream_index] : stream_index
        if @stream_index.nil?
          raise ArgumentError, "The best audio stream is unknown and there is no specified stream."
        end
        if @stream_index >= container_metadata[:streams].length
          raise ArgumentError, "The stream at index #{@stream_index} is not a valid stream."
        end

        @metadata = container_metadata[:streams][@stream_index]
        if !@metadata.key?(:sample_rate)
          raise ArgumentError, "The stream at index #{@stream_index} is not an audio stream."
        end

        @desired_sample_rate =
          !sample_rate.nil? ? sample_rate : @metadata[:sample_rate]

        Core.add_audio_stream(
          @decoder,
          stream_index,
          sample_rate,
          num_channels
        )
      end

      def get_all_samples
        get_samples_played_in_range
      end

      def get_samples_played_in_range(start_seconds: 0.0, stop_seconds: nil)
        if !stop_seconds.nil? && !(start_seconds <= stop_seconds)
          raise ArgumentError, "Invalid start seconds: #{start_seconds}. It must be less than or equal to stop seconds (#{stop_seconds})."
        end
        frames, first_pts = Core.get_frames_by_pts_in_range_audio(
          @decoder,
          start_seconds,
          stop_seconds
        )
        first_pts = first_pts.item

        sample_rate = @desired_sample_rate
        # TODO: metadata's sample_rate should probably not be Optional
        raise if sample_rate.nil?

        if first_pts < start_seconds
          offset_beginning = ((start_seconds - first_pts) * sample_rate).round
          output_pts_seconds = start_seconds
        else
          # In normal cases we'll have first_pts <= start_pts, but in some
          # edge cases it's possible to have first_pts > start_seconds,
          # typically if the stream's first frame's pts isn't exactly 0.
          offset_beginning = 0
          output_pts_seconds = first_pts
        end

        num_samples = frames.shape[1]
        last_pts = first_pts + num_samples / sample_rate
        if !stop_seconds.nil? && stop_seconds < last_pts
          offset_end = num_samples - ((last_pts - stop_seconds) * sample_rate).round
        else
          offset_end = num_samples
        end

        data = frames[0.., offset_beginning...offset_end]
        {
          data: data,
          pts_seconds: output_pts_seconds,
          duration_seconds: data.shape[1] / sample_rate.to_f,
          sample_rate: sample_rate
        }
      end
    end
  end
end
