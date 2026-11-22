// Provide __imp_ pointers for MSVC-import-style references baked into
// MSYS2's prebuilt libjxl/libjxl_cms static objects. The pointers target the
// real functions from static libhwy.a — fully static, no DLL.
namespace hwy {
unsigned long long GetChosenTarget();
unsigned long long SupportedTargets();
}
extern "C" __attribute__((used)) void * const __imp__ZN3hwy15GetChosenTargetEv = (void*)hwy::GetChosenTarget;
extern "C" __attribute__((used)) void * const __imp__ZN3hwy16SupportedTargetsEv = (void*)hwy::SupportedTargets;
