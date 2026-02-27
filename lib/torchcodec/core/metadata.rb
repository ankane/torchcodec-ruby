module TorchCodec
  module Core
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
          raise Todo
        elsif stream_dict["mediaType"] == "audio"
          streams_metadata << {
            sample_rate: stream_dict["sampleRate"],
            num_channels: stream_dict["numChannels"],
            sample_format: stream_dict["sampleFormat"],
            **common_meta
          }
        else
          raise Todo
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
