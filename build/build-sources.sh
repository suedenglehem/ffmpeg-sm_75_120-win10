#!/bin/bash
# Build FFmpeg deps missing from MSYS2, installing into the UCRT64 env.
# Each section is independent; failures are logged, the rest continue.
export PATH=/ucrt64/bin:/usr/bin:/bin
export MSYSTEM=UCRT64
export GIT_TERMINAL_PROMPT=0
export GCM_INTERACTIVE=never
export GIT_CONFIG_NOSYSTEM=1
SRC=/h/vscode/ffmpeg/src
P=/ucrt64
N=$(nproc)
mkdir -p "$SRC" && cd "$SRC" || exit 1

mkpc() { # mkpc <file> <name> <version> <libs> <cflags>
  cat > "$P/lib/pkgconfig/$1.pc" <<EOF
prefix=$P
libdir=\${prefix}/lib
includedir=\${prefix}/include

Name: $2
Description: $2
Version: $3
Libs: $4
Cflags: $5
EOF
}

clone() { # clone <dir> <url>
  [ -d "$1/.git" ] && return 0
  rm -rf "$1"
  git -c credential.helper= clone --depth 1 "$2" "$1"
}

build_cmake() { # build_cmake <srcdir> <builddir> [extra cmake args...]
  local s=$1 b=$2; shift 2
  cmake -G Ninja -S "$s" -B "$b" -DCMAKE_INSTALL_PREFIX=$P -DCMAKE_BUILD_TYPE=Release "$@" \
    && cmake --build "$b" && cmake --install "$b"
}

# ---------- nv-codec-headers (NVENC/NVDEC) ----------
{ clone nv-codec-headers https://github.com/FFmpeg/nv-codec-headers
  cd nv-codec-headers && make install PREFIX=$P && cd ..
  echo "### OK nv-codec-headers"; } || echo "### FAIL nv-codec-headers"

# ---------- quirc (QR decode) ----------
{ clone quirc https://github.com/dlbr/quirc
  cd quirc && make -j$N && make install PREFIX=$P && cd ..
  echo "### OK quirc"; } || echo "### FAIL quirc"

# ---------- libvidstab ----------
{ clone libvidstab https://github.com/georg-martinh/libvidstab
  build_cmake libvidstab b-vidstab -DBUILD_SHARED_LIBS=OFF
  echo "### OK libvidstab"; } || echo "### FAIL libvidstab"

# ---------- game-music-emu ----------
{ clone game-music-emu https://github.com/mpyne/game-music-emu
  build_cmake game-music-emu b-gme -DBUILD_SHARED_LIBS=OFF -DCMAKE_CXX_FLAGS="-fpermissive"
  [ -f $P/lib/pkgconfig/gme.pc ] && cp $P/lib/pkgconfig/gme.pc $P/lib/pkgconfig/libgme.pc
  echo "### OK game-music-emu"; } || echo "### FAIL game-music-emu"

# ---------- astcenc ----------
{ clone astcenc https://github.com/ARM/astcenc
  build_cmake astcenc b-astc -DASTCENC_PROD_LIBS=astcenc -DASTCENC_PROD_TOOLS=off
  echo "### OK astcenc"; } || echo "### FAIL astcenc"

# ---------- uavs3d ----------
{ clone uavs3d https://github.com/uavs3d/uavs3d
  cd uavs3d && make -j$N
  cp buildout/libuavs3d.a $P/lib/ 2>/dev/null || cp libuavs3d.a $P/lib/
  cp include/uavs3d.h $P/include/
  mkpc uavs3d uavs3d 1.1.47 "-luavs3d" "-I$P/include"
  cd ..
  echo "### OK uavs3d"; } || echo "### FAIL uavs3d"

# ---------- davs2 ----------
{ clone Davs2 https://github.com/patrickzw310/Davs2
  cd Davs2 && ./configure --prefix=$P --enable-shared && make -j$N && make install && cd ..
  echo "### OK davs2"; } || echo "### FAIL davs2"

# ---------- xavs2 ----------
{ clone xavs2 https://github.com/mpeg5/xavs2
  cd xavs2 && ./configure --prefix=$P --enable-shared && make -j$N && make install && cd ..
  echo "### OK xavs2"; } || echo "### FAIL xavs2"

# ---------- flite ----------
{ if [ ! -d flite-2.2-beta2 ]; then
    curl -L -o flite.tar.gz https://www.speech.cs.cmu.edu/flite/packed/flite-2.2/flite-2.2-beta2.tar.gz \
      && tar xzf flite.tar.gz
  fi
  cd flite-2.2-beta2 && ./configure --prefix=$P --disable-shared && make -j$N && make install && cd ..
  echo "### OK flite"; } || echo "### FAIL flite"

# ---------- lcevc-dec ----------
{ clone lcevc-dec https://github.com/LLCT-Software/lcevc-dec
  build_cmake lcevc-dec b-lcevc -DCMAKE_CXX_STANDARD=17
  mkpc lcevc_dec lcevc_dec 4.2.0 "-llcevc-dec" "-I$P/include"
  echo "### OK lcevc-dec"; } || echo "### FAIL lcevc-dec"

# ---------- oapv ----------
{ clone oapv https://github.com/oapv/oapv
  build_cmake oapv b-oapv
  mkpc oapv oapv 0.2.0.0 "-loapv" "-I$P/include"
  echo "### OK oapv"; } || echo "### FAIL oapv"

# ---------- svtjpegxs ----------
{ clone svtjpegxs https://gitlab.com/MediaSoftware/svtjpegxs
  build_cmake svtjpegxs b-svtjxs
  mkpc SvtJpegxs SvtJpegxs 0.10.0 "-lSvtJpegxs" "-I$P/include"
  echo "### OK svtjpegxs"; } || echo "### FAIL svtjpegxs"

# ---------- vvenc ----------
{ clone vvenc https://github.com/CiscoGlobalOpenSource/vvenc
  build_cmake vvenc b-vvenc -DVVENC_ENABLE_BUILD_TYPE_SHARED=OFF
  mkpc libvvenc libvvenc 1.13.1 "-lvvenc -lstdc++" "-I$P/include"
  echo "### OK vvenc"; } || echo "### FAIL vvenc"

# ---------- avisynth+ headers (header-only) ----------
{ clone avisynthplus https://github.com/AviSynth/avisynthplus
  mkdir -p $P/include/avisynth
  cp -r avisynthplus/include/* $P/include/avisynth/
  echo "### OK avisynth-headers"; } || echo "### FAIL avisynth-headers"

echo "### SOURCES DONE"
