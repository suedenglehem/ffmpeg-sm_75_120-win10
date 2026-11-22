# FFmpeg Windows Power-Build — static + dynamic, maxed-out library set

Two hand-tuned Windows 64-bit FFmpeg builds produced from **git master** on one MSYS2/CUDA machine:

| Build | Output | What it is |
|---|---|---|
| **STATIC** | `out\bin\ffmpeg.exe` (176 MB) | **100% static** — every library linked in, only Windows system DLLs at runtime. Copy one file anywhere. fdk-aac + **xHE-AAC**, NVENC/NVDEC (sm_75/89/120), ~110 libs, fontconfig, srt/ssh/zmq/disc-read. No vulkan/opencl/DLL-only libs. |
| **DYNAMIC** | `dynamic\out\bin\` (57 MB exes + DLLs) | **Everything enabled** (~120 libs): static's set **plus** whisper (speech→text), codec2, iLBC, qrencode, EVC encode/decode (xeve/xevd), vulkan, OpenCL, libplacebo, OpenColorIO. Ships self-contained with bundled DLLs. |

Both carry version `N-129186-g47f7313e6a-fdk-cuda75-120[-dynamic]` and come with **runnable test suites** (`out\examples\run-all.cmd`, `dynamic\examples\run-all.cmd`) and dedicated READMEs with the full quirk lists.

Static:

ffmpeg version N-129186-g47f7313e6a-fdk-cuda75-120 Copyright (c) 2000-2026 the FFmpeg developers
built with gcc 16.2.0 (Rev7, Built by MSYS2 project)
configuration: --prefix=/h/vscode/ffmpeg/out --pkg-config-flags=--static --extra-cflags='-DLIBTWOLAME_STATIC -DCHROMAPRINT_API_EXPORTS -DCURL_STATI
CLIB -DNGHTTP2_STATICLIB -DLIBSSH_STATIC -DLIBSSH2_STATIC -DPSL_STATIC -DIDN2_STATIC -DCAIRO_WIN32_STATIC_BUILD -DOPJ_STATIC -DXML_STATIC -DLIBXML_
STATIC -DGLIB_STATIC_COMPILATION -DGI_STATIC_COMPILATION -DGIO_STATIC_COMPILATION -DGMODULE_STATIC_COMPILATION -DGOBJECT_STATIC_COMPILATION -DFRIBI
DI_LIB_STATIC -DAL_LIBTYPE_STATIC -DMODPLUG_STATIC -DKHRONOS_STATIC -DLZMA_API_STATIC -DFFI_STATIC_BUILD -DAMQP_STATIC -DZMQ_STATIC -I"C:/cuda128/i
nclude"' --extra-ldflags='-static -L"C:/cuda128/lib" -L"C:/cuda128/lib/x64"' --extra-libs='-lwinmm -lstdc++ -lpng16 -lz -liconv -lharfbuzz -lmpg123
 -lshlwapi -lgomp -lcrypto -lssl -lws2_32 -lbcrypt -lcrypt32 -ladvapi32 -liphlpapi -lole32 -lavrt -luuid -luser32 -lhwy_imp -lhwy' --enable-gpl --e
nable-version3 --enable-nonfree --disable-debug --disable-w32threads --enable-pthreads --enable-libfdk-aac --enable-libfdk-xhe-aac --enable-cairo -
-enable-fontconfig --enable-iconv --enable-gnutls --enable-lcms2 --enable-libxml2 --enable-gmp --enable-bzlib --enable-lzma --enable-libsnappy --en
able-zlib --enable-libcurl --enable-librabbitmq --enable-librist --enable-libsrt --enable-libssh --enable-libzmq --enable-avisynth --enable-libblur
ay --enable-libcaca --enable-libdvdnav --enable-libdvdread --enable-sdl2 --enable-vapoursynth --enable-libaribb24 --enable-libaribcaption --enable-
libdav1d --enable-libdavs2 --enable-liblcevc-dec --enable-libopenjpeg --enable-libquirc --enable-libuavs3d --enable-libxevd --enable-libzvbi --enab
le-libastcenc --enable-liboapv --enable-libqrencode --enable-librav1e --enable-libsvtav1 --enable-libvvenc --enable-libwebp --enable-libx264 --enab
le-libx265 --enable-libxavs2 --enable-libxeve --enable-libxvid --enable-libaom --enable-libjxl --enable-libsvtjpegxs --enable-libvpx --enable-media
foundation --enable-libass --enable-frei0r --enable-libfreetype --enable-libfribidi --enable-libharfbuzz --enable-liblensfun --enable-libopencolori
o --enable-libvidstab --enable-libvmaf --enable-libzimg --enable-amf --enable-cuvid --enable-dxva2 --enable-d3d11va --enable-d3d12va --enable-ffnvc
odec --enable-libvpl --enable-nvdec --enable-nvenc --enable-vaapi --enable-vulkan --enable-libplacebo --enable-opencl --enable-libcdio --enable-ope
nal --enable-libgme --enable-libmodplug --enable-libopenmpt --enable-libopencore-amrwb --enable-libmp3lame --enable-libshine --enable-libtheora --e
nable-libtwolame --enable-libvo-amrwbenc --enable-libcodec2 --enable-libilbc --enable-libgsm --enable-liblc3 --enable-libopencore-amrnb --enable-li
bopus --enable-libspeex --enable-libvorbis --enable-ladspa --enable-libbs2b --enable-libflite --enable-libmysofa --enable-librubberband --enable-li
bsoxr --enable-chromaprint --enable-whisper --enable-libnpp --nvcc='C:/cuda128/bin/nvcc.exe' --nvccflags='-gencode arch=compute_75,code=sm_75 -genc
ode arch=compute_89,code=sm_89 -gencode arch=compute_120,code=sm_120 -gencode arch=compute_120,code=compute_120 -O2' --extra-version=fdk-cuda75-120
 --disable-liboapv --disable-libastcenc --disable-libdavs2 --disable-liblensfun --disable-liblcevc-dec --disable-libquirc --disable-libsvtjpegxs --
disable-libuavs3d --disable-libxavs2 --disable-whisper --disable-libcodec2 --disable-libilbc --disable-libqrencode --disable-libxevd --disable-libx
eve --disable-vulkan --disable-opencl --disable-libplacebo --disable-libopencolorio

libavutil      61. 21.100 / 61. 21.100
libavcodec     63. 28.100 / 63. 28.100
libavformat    63. 21.100 / 63. 21.100
libavdevice    63.  6.100 / 63.  6.100
libavfilter    12. 12.100 / 12. 12.100
libswscale     10.  6.100 / 10.  6.100
libswresample   7.  7.100 /  7.  7.100

Dynamic:

ffmpeg version N-129186-g47f7313e6a-fdk-cuda75-120-dynamic Copyright (c) 2000-2026 the FFmpeg developers
built with gcc 16.2.0 (Rev7, Built by MSYS2 project)
configuration: --prefix=/h/vscode/ffmpeg/dynamic/out --extra-cflags='-I"C:/cuda128/include"' --extra-ldflags='-L"C:/cuda128/lib" -L"C:/cuda128/lib/x64"' --extra
-libs='-lwinmm -lstdc++' --enable-gpl --enable-version3 --enable-nonfree --disable-debug --disable-w32threads --enable-pthreads --enable-libfdk-aac --enable-lib
fdk-xhe-aac --enable-cairo --enable-fontconfig --enable-iconv --enable-gnutls --enable-lcms2 --enable-libxml2 --enable-gmp --enable-bzlib --enable-lzma --enable
-libsnappy --enable-zlib --enable-libcurl --enable-librabbitmq --enable-librist --enable-libsrt --enable-libssh --enable-libzmq --enable-avisynth --enable-libbl
uray --enable-libcaca --enable-libdvdnav --enable-libdvdread --enable-sdl2 --enable-vapoursynth --enable-libaribb24 --enable-libaribcaption --enable-libdav1d --
enable-libdavs2 --enable-liblcevc-dec --enable-libopenjpeg --enable-libquirc --enable-libuavs3d --enable-libxevd --enable-libzvbi --enable-libastcenc --enable-l
iboapv --enable-libqrencode --enable-librav1e --enable-libsvtav1 --enable-libvvenc --enable-libwebp --enable-libx264 --enable-libx265 --enable-libxavs2 --enable
-libxeve --enable-libxvid --enable-libaom --enable-libjxl --enable-libsvtjpegxs --enable-libvpx --enable-mediafoundation --enable-libass --enable-frei0r --enabl
e-libfreetype --enable-libfribidi --enable-libharfbuzz --enable-liblensfun --enable-libopencolorio --enable-libvidstab --enable-libvmaf --enable-libzimg --enabl
e-amf --enable-cuvid --enable-dxva2 --enable-d3d11va --enable-d3d12va --enable-ffnvcodec --enable-libvpl --enable-nvdec --enable-nvenc --enable-vaapi --enable-v
ulkan --enable-libplacebo --enable-opencl --enable-libcdio --enable-openal --enable-libgme --enable-libmodplug --enable-libopenmpt --enable-libopencore-amrwb --
enable-libmp3lame --enable-libshine --enable-libtheora --enable-libtwolame --enable-libvo-amrwbenc --enable-libcodec2 --enable-libilbc --enable-libgsm --enable-
liblc3 --enable-libopencore-amrnb --enable-libopus --enable-libspeex --enable-libvorbis --enable-ladspa --enable-libbs2b --enable-libflite --enable-libmysofa --
enable-librubberband --enable-libsoxr --enable-chromaprint --enable-whisper --enable-libnpp --nvcc='C:/cuda128/bin/nvcc.exe' --nvccflags='-gencode arch=compute_
75,code=sm_75 -gencode arch=compute_89,code=sm_89 -gencode arch=compute_120,code=sm_120 -gencode arch=compute_120,code=compute_120 -O2' --extra-version=fdk-cuda
75-120-dynamic --disable-liboapv --disable-libastcenc --disable-libdavs2 --disable-liblensfun --disable-liblcevc-dec --disable-libquirc --disable-libsvtjpegxs -
-disable-libuavs3d --disable-libxavs2

libavutil      61. 21.100 / 61. 21.100
libavcodec     63. 28.100 / 63. 28.100
libavformat    63. 21.100 / 63. 21.100
libavdevice    63.  6.100 / 63.  6.100
libavfilter    12. 12.100 / 12. 12.100
libswscale     10.  6.100 / 10.  6.100
libswresample   7.  7.100 /  7.  7.100

## Downloads

| Build | Release | Contents |
|---|---|---|
| Static (one-file) | [`static-fdk-cuda75-120`](https://github.com/suedenglehem/ffmpeg-sm_75_120-win10/releases/tag/static-fdk-cuda75-120) | `ffmpeg/ffprobe/ffplay.exe` + fontconfig `.cmd` wrappers (zip, 197 MB) |
| Dynamic (everything) | [`dynamic-fdk-cuda75-120`](https://github.com/suedenglehem/ffmpeg-sm_75_120-win10/releases/tag/dynamic-fdk-cuda75-120) | `bin\` with exes + all 137 DLLs, `examples\` test suite, README (zip, 141 MB) |

Binaries ship as **Release assets** (they exceed GitHub's 100 MB per-file git limit); the repo holds the build system, docs and test suites only.

## Quick start

```
build-all.cmd            ← double-click: builds STATIC first, then DYNAMIC (~40 min)
```
or from a shell: `bash build-all.sh`. Prereqs below; per-build details in [`out/README.md`](out/README.md) and [`dynamic/README.md`](dynamic/README.md).

## Tools used (the toolchain this was built with)

| Tool | Version | Role |
|---|---|---|
| Windows 10 x64 | 19045 | host OS |
| **MSYS2** (`C:\msys64`) | UCRT64 subsystem | build environment — *Cygwin-family* runtime (`msys-2.0.dll`) but **MSYS2, not Cygwin**: native Windows ABI, POSIX shell layer only. The `bash.exe -lc` login shell runs every script. |
| GNU GCC (mingw-w64-ucrt-x86_64) | 16.2.0 | C/C++ compiler, UCRT target |
| GNU binutils | 2.47 | `ld` (the whole static saga), `ar`, `nm`, **`objcopy`** (libssh symbol rename), **`windres`** (resource compile — needs a console, see below) |
| GNU Make | 4.4.1 | FFmpeg build driver |
| pkg-config | 3.0.11 | dependency discovery (FFmpeg caches it in `ffbuild/pkgconfig.cfg`) |
| git for Windows | 2.56.1 | FFmpeg master clone (`FFmpeg/`) |
| **CUDA Toolkit 12.8** (`C:\cuda128`) | r12.8 | NVCC (multi-arch gencode sm_75/89/120) + ffnvcodec headers for NVENC/NVDEC/CUVID |
| pacman (MSYS2) | — | ~120 `mingw-w64-ucrt-x86_64-*` library packages |
| Windows PowerShell 5.1 | — | only used to spawn `windres` inside a hidden **console window** (`build/windres-fftoolsres.ps1`) — windres' popen fails console-less |
| cmd batch files | — | example launchers + `.cmd` wrappers (fontconfig env); must be **CRLF** |

Not Cygwin, not WSL, no Visual Studio: everything is the MSYS2 UCRT64 native toolchain.

## How the builds work

One shared source tree (`FFmpeg/`, git master) is configured twice — never simultaneously:

1. **Static pass** (`build/build-static.sh`)
   - hides **every** `.dll.a` import lib in `/ucrt64/lib` (rename → `.off`) so `-lX` resolves to static `.a`; GNU `ld -static` flatly refuses `.dll.a`
   - compiles with ~25 `-D*_STATIC` / `*_STATICLIB` export macros
   - links a `libhwy_imp.a` shim (MSVC-style `__imp_` pointers baked into MSYS2's prebuilt jxl objects) and rides over the `sha1_init` libssh/libzmq collision
   - graceful-degradation configure loop: each failing probe auto-disables just that lib and retries (fdk is never dropped)
   - `build-static.sh` re-restores the `.dll.a` files on exit (trap + backup restore in `build-all.sh`)
2. **Dynamic pass** (`dynamic/build-dynamic.sh`)
   - auto-`distclean`s the tree when it finds the static config, flips the aribcc header back to shared, and runs the same degradation loop with **zero seed disables** so every DLL-only library gets its chance
   - after install, bundles every resolved MSYS2 DLL into `dynamic\out\bin` (idempotent) so the folder is self-contained — `vulkan-1.dll`/`OpenCL.dll` intentionally stay as the Windows driver-provided ones

System-level patches applied along the way are listed in both sub-READMEs; `build-all.sh` automates the two critical ones (hwy shim, libssh rename) idempotently.

## Repository layout

```
build-all.sh / .cmd        master build (static → dynamic)
build/                     static build scripts (configure-ffmpeg.sh, build-static.sh,
                           hwy_imp.cpp shim, windres ps1) + all build logs
dynamic/                   dynamic build scripts + README + examples
out/                       STATIC deliverable: bin\ + README + examples
FFmpeg/                    git master source tree (upstream — not ours to commit)
src/                       vendored sources (nv-codec-headers, flite, vvenc, …)
downloads/, avisynthplus/    fetched deps          ← build inputs
ffmpeg-n9.0.2-*-win64-gpl-9.0/   a BtbN reference build (not used)
```

## Before pushing to git

- **DELETE `build/.gh-token`** — contains a GitHub token; rotate it, never commit it.
- `.gitignore` provided: excludes `FFmpeg/` (clone it yourself), `out/`, `dynamic/out/`, `src/`, `downloads/`, logs, test artifacts, `.resume`.
- Scripts contain absolute paths (`/h/vscode/ffmpeg`, `C:/cuda128`, `C:\msys64`). If the repo lives elsewhere, adjust `R=`-style vars / the two configure scripts.

## Known quirks (full lists in sub-READMEs)

- `libxeve` needs `-tune zerolatency` (default preset emits empty files — upstream)
- `libxevd` decode can stall after a few frames (upstream; spot-check with `-threads 1 -frames:v 1`)
- fontconfig needs `FONTCONFIG_FILE` — the `.cmd` launchers set it
- this machine has no OpenCL platform (driver stub) — the CUDA paths are the tested ones
- 9 libs missing from *both* builds because their packages aren't installed: oapv, astcenc, davs2, lensfun, lcevc-dec, quirc, svtjpegxs, uavs3d, xavs2
