#include <rice/rice.hpp>

void init_core(Rice::Module m);

extern "C"
void Init_ext() {
  auto rb_mTorchCodec = Rice::define_module("TorchCodec");

  auto rb_mCore = Rice::define_module_under(rb_mTorchCodec, "Core");

  init_core(rb_mCore);
}
