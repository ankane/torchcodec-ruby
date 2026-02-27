require_relative "lib/torchcodec/version"

Gem::Specification.new do |spec|
  spec.name          = "torchcodec"
  spec.version       = TorchCodec::VERSION
  spec.summary       = "Media encoding and decoding for Torch.rb"
  spec.homepage      = "https://github.com/ankane/torchcodec-ruby"
  spec.license       = "BSD-3-Clause"

  spec.author        = "Andrew Kane"
  spec.email         = "andrew@ankane.org"

  spec.files         = Dir["*.{md,txt}", "{ext,lib}/**/*"]
  spec.require_path  = "lib"
  spec.extensions    = ["ext/torchcodec/extconf.rb"]

  spec.required_ruby_version = ">= 3.2"

  spec.add_dependency "torch-rb", ">= 0.23"
end
