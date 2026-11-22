#!/bin/bash
# One-shot static configure (no loop) with import libs hidden; save config.log.
export MSYSTEM=UCRT64
export PATH=/ucrt64/bin:/usr/bin:/bin
B=/h/vscode/ffmpeg/build
cd /ucrt64/lib || exit 1
for f in *.dll.a; do
  case "$f" in libvulkan-1.dll.a|libOpenCL.dll.a) continue;; esac
  mv -- "$f" "$f.off"
done
restore(){ cd /ucrt64/lib; for f in *.dll.a.off; do mv -- "$f" "${f%.off}"; done 2>/dev/null; echo "RESTORED"; }
trap restore EXIT
bash $B/configure-ffmpeg.sh \
  --disable-liboapv --disable-libastcenc --disable-libdavs2 --disable-liblensfun \
  --disable-liblcevc-dec --disable-libquirc --disable-libsvtjpegxs --disable-libuavs3d \
  --disable-libxavs2 --disable-whisper --disable-libcodec2 --disable-libilbc \
  --disable-libqrencode --disable-libxevd --disable-libxeve \
  --disable-vulkan --disable-opencl --disable-libplacebo --disable-libopencolorio \
  > $B/diag-configure.log 2>&1
echo "CONFIGURE_RC=$?"
cp /h/vscode/ffmpeg/FFmpeg/ffbuild/config.log $B/diag-config.log
grep -a "ERROR:" $B/diag-configure.log | head -3
