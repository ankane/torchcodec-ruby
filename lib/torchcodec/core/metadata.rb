module TorchCodec
  module Core
    def self._get_optional_par_fraction(stream_dict)
      begin
        Rational(
          stream_dict.fetch("sampleAspectRatioNum"),
          stream_dict.fetch("sampleAspectRatioDen")
        )
      rescue KeyError
        nil
      end
    end

    def self.get_container_metadata(decoder)
      container_dict = JSON.parse(_get_container_json_metadata(decoder))
      streams_metadata = []

      container_dict["numStreams"].times do |stream_index|
        stream_dict = JSON.parse(_get_stream_json_metadata(decoder, stream_index))
        common_meta = {
          duration_seconds_from_header: stream_dict["durationSecondsFromHeader"],
          duration_seconds: stream_dict["durationSeconds"],
          bit_rate: stream_dict["bitRate"],
          begin_stream_seconds_from_header: stream_dict["beginStreamSecondsFromHeader"],
          begin_stream_seconds: stream_dict["beginStreamSeconds"],
          codec: stream_dict["codec"],
          stream_index: stream_index
        }
        if stream_dict["mediaType"] == "video"
          streams_metadata << {
            begin_stream_seconds_from_content: stream_dict["beginStreamSecondsFromContent"],
            end_stream_seconds_from_content: stream_dict["endStreamSecondsFromContent"],
            end_stream_seconds: stream_dict["endStreamSeconds"],
            num_frames: stream_dict["numFrames"],
            average_fps: stream_dict["averageFps"],
            width: stream_dict["width"],
            height: stream_dict["height"],
            num_frames_from_header: stream_dict["numFramesFromHeader"],
            num_frames_from_content: stream_dict["numFramesFromContent"],
            average_fps_from_header: stream_dict["averageFpsFromHeader"],
            pixel_aspect_ratio: _get_optional_par_fraction(stream_dict),
            **common_meta
          }
        elsif stream_dict["mediaType"] == "audio"
          streams_metadata << {
            sample_rate: stream_dict["sampleRate"],
            num_channels: stream_dict["numChannels"],
            sample_format: stream_dict["sampleFormat"],
            **common_meta
          }
        else
          # This is neither a video nor audio stream. Could be e.g. subtitles.
          # We still need to add a dummy entry so that len(streams_metadata)
          # is consistent with the number of streams.
          streams_metadata << common_meta
        end
      end

      {
        duration_seconds_from_header: container_dict["durationSecondsFromHeader"],
        bit_rate_from_header: container_dict["bitRate"],
        best_video_stream_index: container_dict["bestVideoStreamIndex"],
        best_audio_stream_index: container_dict["bestAudioStreamIndex"],
        streams: streams_metadata
      }
    end
  end
end
