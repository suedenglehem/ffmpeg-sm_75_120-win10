#!/bin/bash
# Wait for source deps, then configure + build FFmpeg.
export PATH=/ucrt64/bin:/usr/bin:/bin
export MSYSTEM=UCRT64
B=/h/vscode/ffmpeg/build

# 1) wait for source builds to finish (fresh machine: no log yet -> assume deps installed)
if [ -f $B/build-sources.log ]; then
  while ! grep -q "SOURCES DONE" $B/build-sources.log 2>/dev/null; do sleep 30; done
  echo "sources finished: $(grep -c '^### OK' $B/build-sources.log) OK, $(grep -c '^### FAIL' $B/build-sources.log) FAIL"
else
  echo "no build-sources.log — assuming dependencies already installed in MSYS2"
fi

# 2) configure with graceful degradation (FDK is never dropped)
DISABLES="$*"
for i in $(seq 1 30); do
  bash $B/configure-ffmpeg.sh $DISABLES > $B/configure.log 2>&1
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

# 3) build
cd /h/vscode/ffmpeg/FFmpeg || exit 1
# windres needs a console; prebuild the single .rc object via hidden console window
if [ ! -f fftools/fftoolsres.o ] || [ ffbuild/config.h -nt fftools/fftoolsres.o ]; then
  powershell.exe -NonInteractive -NoProfile -ExecutionPolicy Bypass -File "$B/windres-fftoolsres.ps1"
fi
make -j$(nproc) > $B/make.log 2>&1 < /dev/null
rc=$?
echo "MAKE_EXIT=$rc"
[ $rc -ne 0 ] && tail -30 $B/make.log
[ $rc -ne 0 ] && exit 1
make install > $B/make-install.log 2>&1 < /dev/null
echo "INSTALL_EXIT=$?"
echo "### BUILD DONE"
