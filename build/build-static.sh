#!/bin/bash
# 100% static rebuild: hide .dll.a import libs so -lX resolves to static .a,
# rebuild FFmpeg with -static, verify ldd shows only system DLLs, restore.
export MSYSTEM=UCRT64
export PATH=/ucrt64/bin:/usr/bin:/bin
B=/h/vscode/ffmpeg/build

# If the tree currently holds the DYNAMIC config, objects compiled without the
# -D*_STATIC macros must not be reused for a static build.
cd /h/vscode/ffmpeg/FFmpeg || exit 1
if [ -f ffbuild/config.mak ] && ! grep -qa -- '-static' ffbuild/config.mak; then
  echo "dynamic config detected — distclean"
  make distclean > $B/distclean.log 2>&1
fi
rm -f ffbuild/pkgconfig.cfg
cd /ucrt64/lib || exit 1
for f in *.dll.a; do
  case "$f" in
    libvulkan-1.dll.a|libOpenCL.dll.a) continue;;   # driver-shipped system DLLs
  esac
  mv -- "$f" "$f.off"
done
echo "HIDDEN: $(ls *.dll.a.off 2>/dev/null | wc -l) import libs"

restore(){
  cd /ucrt64/lib
  for f in *.dll.a.off; do mv -- "$f" "${f%.off}"; done 2>/dev/null
  echo "RESTORED: $(ls *.dll.a 2>/dev/null | wc -l) import libs back"
}
trap restore EXIT

bash $B/build-ffmpeg.sh \
  --disable-liboapv --disable-libastcenc --disable-libdavs2 --disable-liblensfun \
  --disable-liblcevc-dec --disable-libquirc --disable-libsvtjpegxs --disable-libuavs3d \
  --disable-libxavs2 --disable-whisper --disable-libcodec2 --disable-libilbc \
  --disable-libqrencode --disable-libxevd --disable-libxeve \
  --disable-vulkan --disable-opencl --disable-libplacebo --disable-libopencolorio \
  > $B/build-static.log 2>&1
rc=$?
echo "PIPELINE_RC=$rc"
tail -5 $B/build-static.log

if [ -x /h/vscode/ffmpeg/out/bin/ffmpeg.exe ]; then
  echo "=== LDD (non-system deps) ==="
  ldd /h/vscode/ffmpeg/out/bin/ffmpeg.exe 2>/dev/null | grep -aiE "ucrt64|msys" || echo "NONE — fully static (system DLLs only)"
fi
exit $rc
