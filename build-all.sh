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

# Both recipes run --enable-cuda-nvcc: the *_cuda filters (yadif/scale/
# overlay/pad/transpose/…) are a reason these builds exist. In 2025 a
# silently-failing nvcc check shipped binaries with ZERO cuda filters for
# a year — so the toolkit is a HARD requirement here, and every build's
# output is verified below (see ffmpeg.md for the full story).
CUDA_CANDIDATES="C:/cuda128"
have_nvcc(){ [ -f "$1/bin/nvcc.exe" ]; }
NVCC_OK=""
for c in $CUDA_CANDIDATES; do have_nvcc "$c" && NVCC_OK=$c; done

fail_cuda(){
  echo
  echo "CUDA toolkit (nvcc) not found at $CUDA_CANDIDATES."
  echo "These builds REQUIRE it: without a working nvcc check FFmpeg ships"
  echo "NO *_cuda filters — silently, with no build error (that is exactly"
  echo "how the fdk-cuda75-120 releases lost all of them). Install CUDA"
  echo "12.8, or point the CUDA= line in build/configure-ffmpeg.sh and"
  echo "dynamic/configure-dynamic.sh at your toolkit (and build-all.sh here)."
  exit 1
}
[ -n "$NVCC_OK" ] || fail_cuda

# verify_cuda <exe> — the ONLY proof the build is what it claims. A build
# can link fine and still ship zero *_cuda filters (the 2025 failure).
verify_cuda(){
  local n
  n=$("$1" -hide_banner -filters 2>/dev/null | grep -c _cuda)
  [ "$n" -ge 10 ] || fail "$1 has $n cuda filters (expected >= 10: yadif/scale/overlay/pad/transpose/bwdif/colorspace/thumbnail/chromakey/bilateral + hwupload_cuda). nvcc check failed silently — see ffmpeg.md"
  echo "cuda filters: $n ($1)"
}

# nvcc on Windows also needs cl.exe (MSVC host compiler) + cmd.exe on PATH
# and a TMP dir — the drivers/scripts export all of that themselves now,
# but a fresh box without MSVC dies obscurely at rc=255, so say it here.
# (nullglob array: the path has spaces, so an unquoted string would be
# word-split BEFORE globbing — verified live, false-aborts with VS installed.)
shopt -s nullglob
cl_dirs=( "/c/Program Files/Microsoft Visual Studio/2022"/*/VC/Tools/MSVC/*/bin/Hostx64/x64 )
shopt -u nullglob
[ ${#cl_dirs[@]} -gt 0 ] || fail "nvcc needs the MSVC host compiler (cl.exe) under 'C:\Program Files\Microsoft Visual Studio\2022\*\VC\Tools\MSVC\*\bin\Hostx64\x64' — install VS 2022 (VC++ tools) or point --vcvars at another MSVC."

[ -x /ucrt64/bin/gcc.exe ]            || fail "MSYS2 UCRT64 not found at /ucrt64 — install MSYS2 + UCRT64 toolchain"
[ -f "$R/FFmpeg/configure" ]          || fail "FFmpeg source tree missing at $R/FFmpeg (clone FFmpeg master there)"
[ -f "$R/build/configure-ffmpeg.sh" ] || fail "build/ scripts missing"
[ -f /ucrt64/lib/libfdk-aac.a ] || [ -f /ucrt64/lib/libfdk-aac.dll.a ] || fail "libfdk-aac not installed in /ucrt64 (see README §Dependencies)"
echo "nvcc: $NVCC_OK ($("$NVCC_OK/bin/nvcc.exe" --version 2>/dev/null | tail -1))"
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
verify_cuda "$R/out/bin/ffmpeg.exe"
echo "static OK -> $R/out/bin/ffmpeg.exe"

# -------------------- [2/2] DYNAMIC --------------------
echo; echo "==================== [2/2] DYNAMIC BUILD ===================="
bash "$R/dynamic/build-dynamic.sh" || fail "dynamic build failed — see $R/dynamic/build-dynamic.log"
[ -f "$R/dynamic/out/bin/ffmpeg.exe" ] || fail "dynamic exe missing after build"
verify_cuda "$R/dynamic/out/bin/ffmpeg.exe"
echo "dynamic OK -> $R/dynamic/out/bin/ffmpeg.exe"

# -------------------- summary --------------------
echo; echo "==================== ALL BUILDS COMPLETE ===================="
"$R/out/bin/ffmpeg.exe" -hide_banner -version 2>/dev/null | head -1
"$R/dynamic/out/bin/ffmpeg.exe" -hide_banner -version 2>/dev/null | head -1
echo "static : out\\bin\\ffmpeg.exe          (self-contained, system DLLs only)"
echo "dynamic: dynamic\\out\\bin\\ffmpeg.exe   (DLLs bundled; use the .cmd launchers)"
echo "test suites: out\\examples\\run-all.cmd  and  dynamic\\examples\\run-all.cmd"
echo
echo "To ship them (gh CLI logged in as suedenglehem — see ffmpeg.md §Rebuild →"
echo "release for the exact tags/assets): zip each bin/ WITHOUT the test-output"
echo "out/ dirs, tag dynamic-fdk-cuda75-ptx / static-fdk-cuda75-ptx."
