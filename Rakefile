require "bundler/gem_tasks"
require "rake/testtask"
require "rake/extensiontask"
require "ruby_memcheck"

test_config = lambda do |t|
  t.pattern = "test/**/*_test.rb"
end
Rake::TestTask.new(&test_config)

namespace :test do
  RubyMemcheck::TestTask.new(:valgrind, &test_config)
end

task default: :test

Rake::ExtensionTask.new("torchcodec") do |ext|
  ext.name = "ext"
  ext.lib_dir = "lib/torchcodec"
end

task :remove_ext do
  Dir["lib/torchcodec/ext.{bundle,so}"].each do |path|
    File.unlink(path)
  end
end

Rake::Task["build"].enhance [:remove_ext]

def download_file(url)
  require "open-uri"

  file = File.basename(url)
  puts "Downloading #{file}..."
  dest = "test/support/#{file}"
  File.binwrite(dest, URI.parse(url).read)
  puts "Saved #{dest}"
end

namespace :download do
  task :files do
    Dir.mkdir("test/support") unless Dir.exist?("test/support")

    download_file("https://github.com/meta-pytorch/torchcodec/raw/refs/heads/main/test/resources/nasa_13013.mp4.audio.mp3")
  end
end
