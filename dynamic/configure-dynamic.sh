#!/bin/bash
set -x
export PATH=/ucrt64/bin:/usr/bin:/bin:/c/windows/system32:/c/windows
export MSYSTEM=UCRT64
# nvcc on Windows runs its multi-stage compile through %TMP% (and spawns
# cmd.exe — the Windows dirs above). A freshly-spawned bash (a service,
# this script, any -c call) may carry NO TMP at all: nvcc then dies with
# rc=255 and NO output — "failed checking for nvcc" with an empty log was
# exactly this (2026-11-26; verified: TMP="$(cygpath -m /tmp)" makes the
# identical probe pass). Windows-style path: the cmd.exe children need it.
export TMP="$(cygpath -m /tmp)"
export TEMP="$TMP"
CUDA="C:/cuda128"
# --enable-cuda-nvcc makes configure run check_nvcc, and nvcc on Windows
# needs its host compiler (cl.exe) on PATH — "Cannot find compiler
# 'cl.exe' in PATH" otherwise (this exact miss is why the shipped build
# never had the CUDA filters: nvccflags/nvcc were passed but the check
# could not pass without the enable, and cannot pass with it without cl).
#
# nvccflags got TWO more reasons to fail since (the 4-gencode set never
# passed, not even with cl on PATH): configure appends `-ptx` to nvccflags
# GLOBALLY (configure ~L7167) and it also lands in config.mak's NVCCFLAGS,
# which is what builds the real vf_*.cuda.ptx files — FFmpeg embeds PTX
# text per filter and JITs it at load (cuda/load_helper). nvcc refuses
# `-ptx` with more than one -gencode arch ("--ptx is not allowed when
# compiling for multiple GPU architectures"), so multi-arch SASS gencode
# is structurally incompatible with cuda_nvcc. Single PTX arch is the
# design-correct form, and ONE arch covers them all: compute_75 PTX is
# JIT'd forward by the driver on Turing→Blackwell (75/89/100/120 — the
# repo's sm_75_120 range; the build box's 4080 SUPER sm_89 runs it via
# that JIT, verified 2026-11-26). The old 75/89/120 triple could never
# produce a PTX at all under -ptx.
CL_DIR=$(ls -d "/c/Program Files/Microsoft Visual Studio/2022/Enterprise/VC/Tools/MSVC"/*/bin/Hostx64/x64 2>/dev/null | sort -V | tail -1)
[ -n "$CL_DIR" ] && export PATH="$CL_DIR:$PATH"
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
  --extra-version="fdk-cuda75-ptx-dynamic" \
  "$@"
