module TorchCodec
  module Decoders
    def self.create_decoder(source, seek_mode)
      if source.is_a?(String)
        Core.create_from_file(source, seek_mode)
      else
        raise TypeError, "Unknown source type: #{source.class.name}"
      end
    end

    def self._get_cuda_backend
      # TODO improve
      "ffmpeg"
    end
  end
end
