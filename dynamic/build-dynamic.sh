#!/bin/bash
# Dynamic build with every findable lib enabled; no import-lib hiding, no -static.
export MSYSTEM=UCRT64
export PATH=/ucrt64/bin:/usr/bin:/bin
B=/h/vscode/ffmpeg/dynamic
F=/h/vscode/ffmpeg/FFmpeg

# The aribcc header was patched for the static build (ARIBCC_STATIC_LIBRARY).
# Dynamic needs dllimport refs (ARIBCC_SHARED_LIBRARY) to link libaribcaption.dll.a.
sed -i 's/#define ARIBCC_STATIC_LIBRARY/#define ARIBCC_SHARED_LIBRARY/' /ucrt64/include/aribcaption/aribcc_config.h
repatch_static_header() {
  # restore the static-build patch whatever happens, so static recipe stays valid
  sed -i 's/#define ARIBCC_SHARED_LIBRARY/#define ARIBCC_STATIC_LIBRARY/' /ucrt64/include/aribcaption/aribcc_config.h
}
trap repatch_static_header EXIT

# If the tree still holds the static config, objects compiled with -D*_STATIC
# macros must not be reused for a dynamic build.
cd "$F" || exit 1
if grep -qa -- '-static' ffbuild/config.mak 2>/dev/null; then
  echo "static config detected — distclean"
  make distclean > $B/distclean.log 2>&1
fi
rm -f ffbuild/pkgconfig.cfg

# configure with graceful degradation (FDK never dropped); start with zero disables —
# libs that are truly unbuildable (e.g. lensfun API gap) get disabled as they fail.
DISABLES=""
for i in $(seq 1 40); do
  bash $B/configure-dynamic.sh $DISABLES > $B/configure.log 2>&1
  rc=$?
  [ $rc -eq 0 ] && { echo "CONFIGURE OK (round $i)"; break; }
  line=$(grep -a -m1 "ERROR:" $B/configure.log | tr -d '\0')
  echo "round $i: $line"
  opt=""
  case "$line" in
    *vidstab*) opt=libvidstab;; *gme*|*game*) opt=libgme;; *astcenc*) opt=libastcenc;;
    *uavs3d*) opt=libuavs3d;; *davs2*) opt=libdavs2;; *xavs2*) opt=libxavs2;;
    *flite*) opt=libflite;; *lcevc*) opt=liblcevc-dec;; *oapv*) opt=liboapv;;
    *[Ss]vt[Jj]peg*|*jpegxs*) opt=libsvtjpegxs;; *vvenc*) opt=libvvenc;;
    *avisynth*) opt=avisynth;;
    *quirc*) opt=libquirc;; *vapoursynth*) opt=vapoursynth;; *frei0r*) opt=frei0r;;
    *whisper*) opt=whisper;; *placebo*) opt=libplacebo;; *vpl*) opt=libvpl;;
    *va*) opt=vaapi;; *amf*) opt=amf;; *npp*) opt=libnpp;; *cairo*) opt=cairo;;
    *lensfun*) opt=liblensfun;; *opencolorio*|*ColorIO*) opt=libopencolorio;;
    *vmaf*) opt=libvmaf;; *zvbi*) opt=libzvbi;; *rabbitmq*) opt=librabbitmq;;
    *cdio*) opt=libcdio;; *rist*) opt=librist;; *xhe*) opt=libfdk-xhe-aac;;
    *codec2*) opt=libcodec2;; *ilbc*) opt=libilbc;; *qrencode*) opt=libqrencode;;
    *xevd*) opt=libxevd;; *xeve*) opt=libxeve;; *vulkan*) opt=vulkan;;
    *opencl*) opt=opencl;;
    *fdk*) echo "FDK failure — NOT disabling, aborting loop"; break;;
  esac
  if [ -z "$opt" ]; then
    opt=$(printf '%s' "$line" | sed -E 's/.*ERROR: ([A-Za-z0-9_.+-]+).*/\1/')
    case "$opt" in libva) opt=vaapi;; aribb24) opt=libaribb24;; harfbuzz) opt=libharfbuzz;; esac
    [ "$opt" = "$line" ] && { echo "unmapped configure error, stopping"; tail -30 $B/configure.log; break; }
  fi
  DISABLES="$DISABLES --disable-$opt"
done
[ $rc -ne 0 ] && { echo "CONFIGURE FAILED"; exit 1; }

# windres needs a console; prebuild the single .rc object via hidden console window
cd /h/vscode/ffmpeg/FFmpeg || exit 1
if [ ! -f fftools/fftoolsres.o ] || [ ffbuild/config.h -nt fftools/fftoolsres.o ]; then
  # powershell.exe is not on the stripped PATH — use the absolute path
  /c/windows/System32/WindowsPowerShell/v1.0/powershell.exe -NonInteractive -NoProfile -ExecutionPolicy Bypass -File /h/vscode/ffmpeg/build/windres-fftoolsres.ps1
fi

make -j$(nproc) > $B/make.log 2>&1 < /dev/null
rc=$?
echo "MAKE_EXIT=$rc"
[ $rc -ne 0 ] && tail -30 $B/make.log
[ $rc -ne 0 ] && exit 1
make install > $B/make-install.log 2>&1 < /dev/null
echo "INSTALL_EXIT=$?"
# bundle resolved msys DLL deps next to the exes -> self-contained folder (idempotent)
if [ -x /h/vscode/ffmpeg/dynamic/out/bin/ffmpeg.exe ]; then
  cd /h/vscode/ffmpeg/dynamic/out/bin || exit 1
  for e in ffmpeg.exe ffprobe.exe ffplay.exe; do
    ldd "$e" | awk '/=> \//{print $3}' | grep -aiE 'msys|ucrt64' | while read -r p; do
      [ -f "$p" ] && cp -n "$p" . 2>/dev/null
    done
  done
  echo "BUNDLED_DLLS: $(ls *.dll 2>/dev/null | wc -l)"
  cd "$F" || exit 1
fi
echo "### DYNAMIC BUILD DONE"
if [ -x /h/vscode/ffmpeg/dynamic/out/bin/ffmpeg.exe ]; then
  echo "=== DLL DEPS (msys libs expected — dynamic build) ==="
  ldd /h/vscode/ffmpeg/dynamic/out/bin/ffmpeg.exe | grep -aci "ucrt64\|msys"
  ldd /h/vscode/ffmpeg/dynamic/out/bin/ffmpeg.exe | grep -aiE "whisper|ggml|vulkan|OpenCL|placebo|codec2|ilbc|qrencode|xevd|xeve|shaderc|spirv" || true
fi
echo "DISABLED: $DISABLES"
