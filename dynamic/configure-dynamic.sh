#!/bin/bash
set -x
export PATH=/ucrt64/bin:/usr/bin:/bin
export MSYSTEM=UCRT64
CUDA="C:/cuda128"
cd /h/vscode/ffmpeg/FFmpeg || exit 1

./configure \
  --prefix=/h/vscode/ffmpeg/dynamic/out \
  --extra-cflags="-I\"$CUDA/include\"" \
  --extra-ldflags="-L\"$CUDA/lib\" -L\"$CUDA/lib/x64\"" \
  --extra-libs="-lwinmm -lstdc++" \
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
  --nvccflags="-gencode arch=compute_75,code=sm_75 -gencode arch=compute_89,code=sm_89 -gencode arch=compute_120,code=sm_120 -gencode arch=compute_120,code=compute_120 -O2" \
  --extra-version="fdk-cuda75-120-dynamic" \
  "$@"
