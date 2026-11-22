#!/bin/bash
# Clone + build GitHub-only FFmpeg deps using authenticated access.
export PATH=/ucrt64/bin:/usr/bin:/bin
export MSYSTEM=UCRT64
export GIT_TERMINAL_PROMPT=0 GIT_CONFIG_NOSYSTEM=1
T=$(cat /h/vscode/ffmpeg/build/.gh-token | tr -d '\r\n')
SRC=/h/vscode/ffmpeg/src; P=/ucrt64; N=$(nproc)
cd "$SRC" || exit 1

clone_gh() { # clone_gh <dir> <owner/repo>
  [ -d "$1/.git" ] && return 0
  rm -rf "$1"
  git -c credential.helper= clone --depth 1 "https://x-access-token:$T@github.com/$2.git" "$1" >/dev/null 2>&1
}

pc() { # pc <file> <name> <version> <libs> <cflags>
  printf 'prefix=%s\nlibdir=${prefix}/lib\nincludedir=${prefix}/include\n\nName: %s\nDescription: %s\nVersion: %s\nLibs: %s\nCflags: %s\n' \
    "$P" "$2" "$2" "$3" "$4" "$5" > "$P/lib/pkgconfig/$1.pc"
}

# --- quirc ---
if clone_gh quirc dlbr/quirc && ( cd quirc && make -j$N >/dev/null && make install PREFIX=$P >/dev/null ); then echo "### OK quirc"; else echo "### FAIL quirc"; fi

# --- astcenc ---
if clone_gh astcenc ARM/astcenc && cmake -G Ninja -S astcenc -B b-astc -DCMAKE_INSTALL_PREFIX=$P -DASTCENC_PROD_LIBS=astcenc -DASTCENC_PROD_TOOLS=off >/dev/null && cmake --build b-astc >/dev/null && cmake --install b-astc >/dev/null; then echo "### OK astcenc"; else echo "### FAIL astcenc"; fi

# --- uavs3d ---
if clone_gh uavs3d uavs3d/uavs3d && ( cd uavs3d && make -j$N >/dev/null && { cp buildout/libuavs3d.a $P/lib/ 2>/dev/null || cp libuavs3d.a $P/lib/; } && cp include/uavs3d.h $P/include/ ) && pc uavs3d uavs3d 1.1.47 "-luavs3d" "-I$P/include"; then echo "### OK uavs3d"; else echo "### FAIL uavs3d"; fi

# --- davs2 ---
if clone_gh Davs2 patrickzw310/Davs2 && ( cd Davs2 && ./configure --prefix=$P --enable-shared >/dev/null && make -j$N >/dev/null && make install >/dev/null ); then echo "### OK davs2"; else echo "### FAIL davs2"; fi

# --- xavs2 ---
if clone_gh xavs2 mpeg5/xavs2 && ( cd xavs2 && ./configure --prefix=$P --enable-shared >/dev/null && make -j$N >/dev/null && make install >/dev/null ); then echo "### OK xavs2"; else echo "### FAIL xavs2"; fi

# --- lcevc-dec ---
if clone_gh lcevc-dec LLCT-Software/lcevc-dec && cmake -G Ninja -S lcevc-dec -B b-lcevc -DCMAKE_CXX_STANDARD=17 >/dev/null && cmake --build b-lcevc >/dev/null && cmake --install b-lcevc >/dev/null && pc lcevc_dec lcevc_dec 4.2.0 "-llcevc-dec" "-I$P/include"; then echo "### OK lcevc-dec"; else echo "### FAIL lcevc-dec"; fi

# --- oapv ---
if clone_gh oapv oapv/oapv && cmake -G Ninja -S oapv -B b-oapv >/dev/null && cmake --build b-oapv >/dev/null && cmake --install b-oapv >/dev/null && pc oapv oapv 0.2.0.0 "-loapv" "-I$P/include"; then echo "### OK oapv"; else echo "### FAIL oapv"; fi

# --- vvenc ---
if clone_gh vvenc CiscoGlobalOpenSource/vvenc && cmake -G Ninja -S vvenc -B b-vvenc -DCMAKE_BUILD_TYPE=Release >/dev/null && cmake --build b-vvenc >/dev/null && cmake --install b-vvenc >/dev/null && pc libvvenc libvvenc 1.13.1 "-lvvenc -lstdc++" "-I$P/include"; then echo "### OK vvenc"; else echo "### FAIL vvenc"; fi

# --- svtjpegxs (gitlab) ---
if [ ! -d svtjpegxs/.git ]; then rm -rf svtjpegxs; git -c credential.helper= clone --depth 1 https://gitlab.com/MediaSoftware/svtjpegxs.git svtjpegxs >/dev/null 2>&1; fi
if [ -d svtjpegxs/.git ] && cmake -G Ninja -S svtjpegxs -B b-svtjxs -DCMAKE_BUILD_TYPE=Release >/dev/null && cmake --build b-svtjxs >/dev/null && cmake --install b-svtjxs >/dev/null && pc SvtJpegxs SvtJpegxs 0.10.0 "-lSvtJpegxs" "-I$P/include"; then echo "### OK svtjpegxs"; else echo "### FAIL svtjpegxs"; fi

echo "### GH DONE"
