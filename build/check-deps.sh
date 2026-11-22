#!/bin/bash
# Check MSYS2 package availability for the FFmpeg dependency set
P=mingw-w64-x86_64
PKGS="
$P-zlib $P-bzip2 $P-xz $P-libpng $P-freetype $P-fontconfig $P-harfbuzz $P-fribidi $P-libass
$P-x264 $P-x265 $P-xvidcore $P-libvpx $P-libaom $P-rav1e $P-svt-av1 $P-libvvenc $P-libjxl
$P-libwebp $P-openjpeg $P-snappy $P-libxml2 $P-gmp $P-gnutls $P-libiconv $P-lcms2 $P-curl
$P-librist $P-srt $P-libssh $P-zeromq $P-rabbitmq-c $P-libbluray $P-libcaca $P-libdvdnav $P-libdvdread
$P-SDL2 $P-vapoursynth $P-libaribb24 $P-dav1d $P-zvbi $P-qrencode $P-opencolorio $P-lensfun
$P-libvidstab $P-libvmaf $P-libzimg $P-libplacebo $P-vulkan-headers $P-vulkan-loader $P-opencl-icd
$P-libva $P-onevpl $P-libcdio $P-openal-soft $P-game-music-emu $P-libmodplug $P-libopenmpt
$P-opencore-amr $P-vo-amrwbenc $P-mp3lame $P-shine $P-libtheora $P-twolame $P-libcodec2
$P-libgsm $P-speex $P-libvorbis $P-opus $P-ladspa-sdk $P-libbs2b $P-libmysofa $P-rubberband
$P-soxr $P-chromaprint $P-frei0r $P-cairo $P-whisper-cpp $P-amf $P-quirc $P-aribcaption
$P-astcenc $P-uavs3d $P-davs2 $P-xavs2 $P-libxeve $P-libxevd $P-liblc3 $P-flite $P-libilbc
$P-libfdk-aac $P-fdk-aac
"
for p in $PKGS; do
  if pacman -S --print --noconfirm "$p" >/dev/null 2>&1; then
    echo "OK   $p"
  else
    echo "MISS $p"
  fi
done
