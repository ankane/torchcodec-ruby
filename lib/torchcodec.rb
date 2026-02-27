# dependencies
require "torch"

# ext
require "torchcodec/ext"

# stdlib
require "json"

# modules
require_relative "torchcodec/version"

# core
require_relative "torchcodec/core/metadata"

# decoders
require_relative "torchcodec/decoders/audio_decoder"
require_relative "torchcodec/decoders/decoder_utils"
require_relative "torchcodec/decoders/video_decoder"

# encoders
require_relative "torchcodec/encoders/audio_encoder"
require_relative "torchcodec/encoders/video_encoder"

# transforms
require_relative "torchcodec/transforms/decoder_transforms"

module TorchCodec
  class Error < StandardError; end

  class Todo < Error
    def message
      "not implemented yet"
    end
  end
end
