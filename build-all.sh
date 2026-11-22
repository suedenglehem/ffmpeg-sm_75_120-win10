#!/bin/bash
# ============================================================================
#  FFmpeg Windows power-build — master script
#  Builds STATIC first, then DYNAMIC, from one MSYS2 UCRT64 + CUDA 12.8 box.
#
#  Outputs:
#    H:\vscode\ffmpeg\out\bin\            static, zero DLLs
#    H:\vscode\ffmpeg\dynamic\out\bin\    dynamic, all libs + bundled DLLs
#
#  Run:  bash build-all.sh    (or double-click build-all.cmd)
#  Takes ~40 min for both from a clean FFmpeg tree.
# ============================================================================
export MSYSTEM=UCRT64
export PATH=/ucrt64/bin:/usr/bin:/bin
R=$(cd "$(dirname "$0")" && pwd)     # repo root (posix path)

fail(){ echo; echo "!!! BUILD ABORTED: $*"; exit 1; }

echo "==================== PREFLIGHT ===================="
[ -x /ucrt64/bin/gcc.exe ]            || fail "MSYS2 UCRT64 not found at /ucrt64 — install MSYS2 + UCRT64 toolchain"
[ -f "$R/FFmpeg/configure" ]          || fail "FFmpeg source tree missing at $R/FFmpeg (clone FFmpeg master there)"
[ -f "$R/build/configure-ffmpeg.sh" ] || fail "build/ scripts missing"
[ -f /ucrt64/lib/libfdk-aac.a ] || [ -f /ucrt64/lib/libfdk-aac.dll.a ] || fail "libfdk-aac not installed in /ucrt64 (see README §Dependencies)"
if [ ! -f "C:/cuda128/bin/nvcc.exe" ]; then
  echo "WARNING: CUDA toolkit not at C:/cuda128 — NVENC/NVDEC probes will fail and the"
  echo "         degradation loop will drop nvenc/nvdec/cuvid. Install CUDA 12.8 or"
  echo "         adjust the CUDA path in build/configure-ffmpeg.sh."
fi
echo "preflight OK"

# -------------------- one-time MSYS2 system prep (idempotent) --------------------
# 1) hwy import shim: MSYS2's static libjxl_cms.a has __imp_hwy dllimport refs
#    baked in; the static link needs this shim (see README §Static tricks).
if [ ! -f /ucrt64/lib/libhwy_imp.a ]; then
  echo "building /ucrt64/lib/libhwy_imp.a shim..."
  cd "$R/build" || fail "build dir"
  g++ -static -c hwy_imp.cpp -o /tmp/hwy_imp.o && ar rcs /ucrt64/lib/libhwy_imp.a /tmp/hwy_imp.o \
    || fail "libhwy_imp.a shim build failed"
fi
# 2) libssh.a vs libzmq.a both export sha1_init — rename in libssh (static link fix)
if nm /ucrt64/lib/libssh.a 2>/dev/null | grep -qw "T sha1_init"; then
  echo "renaming sha1_init -> ssh_sha1_init inside libssh.a..."
  [ -f /ucrt64/lib/libssh.a.orig ] || cp /ucrt64/lib/libssh.a /ucrt64/lib/libssh.a.orig
  printf 'sha1_init ssh_sha1_init\n' > /tmp/sha1.syms
  objcopy --redefine-syms=/tmp/sha1.syms /ucrt64/lib/libssh.a || fail "libssh sha1 rename failed"
fi

# -------------------- [1/2] STATIC --------------------
echo; echo "==================== [1/2] STATIC BUILD ===================="
bash "$R/build/build-static.sh"
SRC=$?
# safety net: restore hidden import libs if the static pipeline died hard (trap missed)
if ls /ucrt64/lib/*.dll.a.off >/dev/null 2>&1; then
  echo "restoring leftover hidden import libs..."
  for f in /ucrt64/lib/*.dll.a.off; do mv -- "$f" "${f%.off}"; done
fi
[ $SRC -eq 0 ] || fail "static build failed — see $R/build/build-static.log"
[ -f "$R/out/bin/ffmpeg.exe" ] || fail "static exe missing after build"
echo "static OK -> $R/out/bin/ffmpeg.exe"

# -------------------- [2/2] DYNAMIC --------------------
echo; echo "==================== [2/2] DYNAMIC BUILD ===================="
bash "$R/dynamic/build-dynamic.sh" || fail "dynamic build failed — see $R/dynamic/build-dynamic.log"
[ -f "$R/dynamic/out/bin/ffmpeg.exe" ] || fail "dynamic exe missing after build"
echo "dynamic OK -> $R/dynamic/out/bin/ffmpeg.exe"

# -------------------- summary --------------------
echo; echo "==================== ALL BUILDS COMPLETE ===================="
"$R/out/bin/ffmpeg.exe" -hide_banner -version 2>/dev/null | head -1
"$R/dynamic/out/bin/ffmpeg.exe" -hide_banner -version 2>/dev/null | head -1
echo "static : out\\bin\\ffmpeg.exe          (self-contained, system DLLs only)"
echo "dynamic: dynamic\\out\\bin\\ffmpeg.exe   (DLLs bundled; use the .cmd launchers)"
echo "test suites: out\\examples\\run-all.cmd  and  dynamic\\examples\\run-all.cmd"
