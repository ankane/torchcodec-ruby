require "mkmf-rice"

$CXXFLAGS += " -std=c++17 $(optflags)"

paths = []
if RbConfig::CONFIG["host_os"] =~ /darwin/i
  if RbConfig::CONFIG["host_cpu"] =~ /arm|aarch64/i
    paths << "/opt/homebrew"
  else
    paths << "/usr/local"
  end
elsif !Gem.win_platform?
  paths << "/home/linuxbrew/.linuxbrew"
end

inc, lib = dir_config("torch")
inc ||= paths.map { |v| "#{v}/opt/pytorch/include" }.find { |v| Dir.exist?("#{v}/torch") }
lib ||= paths.map { |v| "#{v}/opt/pytorch/lib" }.find { |v| Dir["#{v}/*torch_cpu*"].any? }

unless inc && lib
  abort "LibTorch not found"
end

cuda_inc, cuda_lib = dir_config("cuda")
cuda_lib ||= "/usr/local/cuda/lib64"

cudnn_inc, cudnn_lib = dir_config("cudnn")
cudnn_lib ||= "/usr/local/cuda/lib"

$LDFLAGS += " -L#{lib}" if Dir.exist?(lib)
abort "LibTorch not found" unless have_library("torch")

have_library("mkldnn")
have_library("nnpack")

with_cuda = false
if Dir["#{lib}/*torch_cuda*"].any?
  $LDFLAGS += " -L#{cuda_lib}" if Dir.exist?(cuda_lib)
  $LDFLAGS += " -L#{cudnn_lib}" if Dir.exist?(cudnn_lib) && cudnn_lib != cuda_lib
  with_cuda = have_library("cuda") && have_library("cudnn")
end

$INCFLAGS += " -I#{inc}"
$INCFLAGS += " -I#{inc}/torch/csrc/api/include"

$LDFLAGS += " -Wl,-rpath,#{lib}"
$LDFLAGS += ":#{cuda_lib}/stubs:#{cuda_lib}" if with_cuda

# https://github.com/pytorch/pytorch/blob/v2.9.0/torch/utils/cpp_extension.py#L1351-L1364
$LDFLAGS += " -lc10 -ltorch_cpu -ltorch"
if with_cuda
  $LDFLAGS += " -lcuda -lnvrtc"
  $LDFLAGS += " -lnvToolsExt" if File.exist?("#{cuda_lib}/libnvToolsExt.so")
  $LDFLAGS += " -lcudart -lc10_cuda -ltorch_cuda -lcufft -lcurand -lcublas -lcudnn"
  # TODO figure out why this is needed
  $LDFLAGS += " -Wl,--no-as-needed,#{lib}/libtorch.so"
end

ffmpeg_inc, ffmpeg_lib = dir_config("ffmpeg")
ffmpeg_inc ||= paths.map { |v| "#{v}/opt/ffmpeg/include" }.find { |v| File.exist?("#{v}/libavcodec/avcodec.h") }
ffmpeg_lib ||= paths.map { |v| "#{v}/opt/ffmpeg/lib" }.find { |v| Dir["#{v}/*libavcodec*"].any? }

ffmpeg_incs = ffmpeg_inc ? [ffmpeg_inc] : []
ffmpeg_libs = ffmpeg_lib ? [ffmpeg_lib] : []

abort "libavcodec not found" unless find_header("libavcodec/avcodec.h", *ffmpeg_incs)
abort "libavcodec not found" unless find_library("avcodec", nil, *ffmpeg_libs)
abort "libavdevice not found" unless find_library("avdevice", nil, *ffmpeg_libs)
abort "libavfilter not found" unless find_library("avfilter", nil, *ffmpeg_libs)
abort "libavutil not found" unless find_library("avutil", nil, *ffmpeg_libs)

# create makefile
create_makefile("torchcodec/ext")
