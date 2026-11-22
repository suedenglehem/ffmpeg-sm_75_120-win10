#!/bin/bash
# Install FFmpeg dependency set in MSYS2 UCRT64 environment
set -x
pacman -Syu --noconfirm 2>&1 | tail -1
pacman -Syu --noconfirm 2>&1 | tail -1
P=mingw-w64-ucrt-x86_64
pacman -S --noconfirm --needed \
  base git make autoconf automake libtool pkgconf texinfo diffutils patch \
  perl m4 unzip zip p7zip python python-setuptools python-pip \
  $P-toolchain $P-cmake $P-meson $P-ninja $P-nasm $P-yasm $P-pkgconf $P-gettext \
  $P-zlib $P-bzip2 $P-xz $P-libpng $P-freetype $P-fontconfig $P-harfbuzz $P-fribidi $P-libass \
  $P-x264 $P-x265 $P-xvidcore $P-libvpx $P-aom $P-rav1e $P-svt-av1 $P-libjxl $P-xevd $P-xeve\
  $P-libwebp $P-openjpeg2 $P-snappy $P-libxml2 $P-gmp $P-gnutls $P-libiconv $P-lcms2 $P-curl \
  $P-librist $P-srt $P-libssh $P-zeromq $P-rabbitmq-c $P-libbluray $P-libcaca $P-libdvdnav $P-libdvdread \
  $P-SDL2 $P-vapoursynth $P-aribb24 $P-libaribcaption $P-dav1d $P-zvbi $P-qrencode $P-opencolorio $P-lensfun \
  $P-vmaf $P-zimg $P-libplacebo $P-vulkan-headers $P-vulkan-loader $P-opencl-icd $P-opencl-headers \
  $P-libva $P-onevpl $P-libcdio $P-libmodplug $P-libopenmpt \
  $P-opencore-amr $P-vo-amrwbenc $P-lame $P-shine $P-libtheora $P-twolame $P-codec2 \
  $P-gsm $P-speex $P-libvorbis $P-opus $P-ladspa-sdk $P-libbs2b $P-libmysofa $P-rubberband \
  $P-libsoxr $P-chromaprint $P-frei0r-plugins $P-cairo $P-whisper.cpp $P-amf-headers \
  $P-liblc3 $P-libilbc $P-fdk-aac
echo "PACMAN_EXIT=$?"
