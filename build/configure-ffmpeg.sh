#!/bin/bash
set -x
# nvcc on Windows needs: cl.exe (its host compiler), the Windows dirs (it
# spawns cmd.exe) and TMP (without a temp dir nvcc dies SILENTLY, rc=255 —
# "failed checking for nvcc" with an empty log; 2026-11-26). Same fix as
# dynamic/configure-dynamic.sh, where the full story is written down.
export PATH=/ucrt64/bin:/usr/bin:/bin:/c/windows/system32:/c/windows
CL_DIR=$(ls -d "/c/Program Files/Microsoft Visual Studio/2022/Enterprise/VC/Tools/MSVC"/*/bin/Hostx64/x64 2>/dev/null | sort -V | tail -1)
[ -n "$CL_DIR" ] && export PATH="$CL_DIR:$PATH"
export TMP="$(cygpath -m /tmp)"
export TEMP="$TMP"
export MSYSTEM=UCRT64
CUDA="C:/cuda128"
cd /h/vscode/ffmpeg/FFmpeg || exit 1

# NOTE: no comment lines may sit INSIDE the ./configure \ continuation
# below — backslash-newline joins them into the command, where a '#'
# silently comments out every remaining option (observed 2026-11-26).
#
# cuda filters (2026-11-26): --enable-cuda-nvcc + a SINGLE pure-PTX
# -gencode arch. cuda_nvcc appends -ptx to nvccflags globally, and nvcc
# forbids -ptx with multiple -gencode archs — the old 75/89/120 SASS
# triple could NEVER pass check_nvcc, which is why the shipped static
# build had zero *_cuda filters. compute_75 PTX is driver-JIT'd forward
# on Turing→Blackwell (the repo's sm_75_120 range). Full story:
# dynamic/configure-dynamic.sh header.

./configure \
  --prefix=/h/vscode/ffmpeg/out \
  --pkg-config-flags=--static \
  --extra-cflags="-DLIBTWOLAME_STATIC -DCHROMAPRINT_API_EXPORTS -DCURL_STATICLIB -DNGHTTP2_STATICLIB -DLIBSSH_STATIC -DLIBSSH2_STATIC -DPSL_STATIC -DIDN2_STATIC -DCAIRO_WIN32_STATIC_BUILD -DOPJ_STATIC -DXML_STATIC -DLIBXML_STATIC -DGLIB_STATIC_COMPILATION -DGI_STATIC_COMPILATION -DGIO_STATIC_COMPILATION -DGMODULE_STATIC_COMPILATION -DGOBJECT_STATIC_COMPILATION -DFRIBIDI_LIB_STATIC -DAL_LIBTYPE_STATIC -DMODPLUG_STATIC -DKHRONOS_STATIC -DLZMA_API_STATIC -DFFI_STATIC_BUILD -DAMQP_STATIC -DZMQ_STATIC -I\"$CUDA/include\"" \
  --extra-ldflags="-static -L\"$CUDA/lib\" -L\"$CUDA/lib/x64\"" \
  --extra-libs="-lwinmm -lstdc++ -lpng16 -lz -liconv -lharfbuzz -lmpg123 -lshlwapi -lgomp -lcrypto -lssl -lws2_32 -lbcrypt -lcrypt32 -ladvapi32 -liphlpapi -lole32 -lavrt -luuid -luser32 -lhwy_imp -lhwy" \
  --enable-gpl --enable-version3 --enable-nonfree \
  --disable-debug \
  --disable-w32threads --enable-pthreads \
  --enable-libfdk-aac --enable-libfdk-xhe-aac \
  --enable-cairo --enable-fontconfig --enable-iconv --enable-gnutls --enable-lcms2 \
  --enable-libxml2 --enable-gmp --enable-bzlib --enable-lzma --enable-libsnappy --enable-zlib \
  --enable-libcurl --enable-librabbitmq --enable-librist --enable-libsrt --enable-libssh --enable-libzmq \
  --enable-avisynth --enable-libbluray --enable-libcaca --enable-libdvdnav --enable-libdvdread \
  --enable-sdl2 --enable-vapoursynth \
  --enable-libaribb24 --enable-libaribcaption --enable-libdav1d --enable-libdavs2 \
  --enable-liblcevc-dec --enable-libopenjpeg --enable-libquirc --enable-libuavs3d --enable-libxevd \
  --enable-libzvbi --enable-libastcenc --enable-liboapv --enable-libqrencode \
  --enable-librav1e --enable-libsvtav1 --enable-libvvenc --enable-libwebp \
  --enable-libx264 --enable-libx265 --enable-libxavs2 --enable-libxeve --enable-libxvid \
  --enable-libaom --enable-libjxl --enable-libsvtjpegxs --enable-libvpx \
  --enable-mediafoundation --enable-libass --enable-frei0r --enable-libfreetype \
  --enable-libfribidi --enable-libharfbuzz --enable-liblensfun --enable-libopencolorio \
  --enable-libvidstab --enable-libvmaf --enable-libzimg \
  --enable-amf --enable-cuvid --enable-dxva2 --enable-d3d11va --enable-d3d12va \
  --enable-ffnvcodec --enable-libvpl --enable-nvdec --enable-nvenc \
  --enable-cuda-nvcc \
  --enable-vaapi --enable-vulkan --enable-libplacebo --enable-opencl \
  --enable-libcdio --enable-openal --enable-libgme --enable-libmodplug --enable-libopenmpt \
  --enable-libopencore-amrwb --enable-libmp3lame --enable-libshine --enable-libtheora \
  --enable-libtwolame --enable-libvo-amrwbenc --enable-libcodec2 --enable-libilbc \
  --enable-libgsm --enable-liblc3 --enable-libopencore-amrnb --enable-libopus \
  --enable-libspeex --enable-libvorbis --enable-ladspa --enable-libbs2b --enable-libflite \
  --enable-libmysofa --enable-librubberband --enable-libsoxr --enable-chromaprint \
  --enable-whisper \
  --enable-libnpp \
  --nvcc="C:/cuda128/bin/nvcc.exe" \
  --nvccflags="-gencode arch=compute_75,code=compute_75 -O2" \
  --extra-version="fdk-cuda75-ptx-static" \
  "$@"
