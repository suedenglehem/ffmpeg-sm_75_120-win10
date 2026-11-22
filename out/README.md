# FFmpeg Static Build — `fdk-cuda75-120` (100% static)

Windows 64-bit build from git master (`N-129186-g47f7313e6a`), built 2026-11-22. One self-contained executable: **zero third-party DLLs** — `ffmpeg.exe` links ~110 libraries statically and needs only standard Windows system DLLs. Copy it to any x64 Windows machine and it runs.

| Build | Location | Character |
|---|---|---|
| **Static** (this) | `H:\vscode\ffmpeg\out\bin` | one 176 MB exe, no DLLs, CUDA/NVENC only, **no** whisper/codec2/ilbc/qrencode/EVC/vulkan/opencl/placebo/opencolorio |
| **Dynamic** | `H:\vscode\ffmpeg\dynamic\out\bin` | 57 MB exes + DLLs, **everything** enabled — use it when you need those 10 |

## Folder layout

```
out\
├─ README.md                 ← this file
├─ bin\
│  ├─ ffmpeg.exe  (176 MB — contains everything)
│  ├─ ffprobe.exe / ffplay.exe
│  └─ ffmpeg.cmd / ffprobe.cmd / ffplay.cmd   ← use THESE (set fontconfig)
└─ examples\                 ← runnable test scripts
   └─ run-all.cmd            ← runs everything, prints PASS/FAIL
```

## How to run

Use the `.cmd` wrappers — they set `FONTCONFIG_FILE` so `drawtext`/subtitles find fonts. The bare `ffmpeg.exe` works for everything else (no DLLs to worry about), it just prints fontconfig warnings in a bare Windows shell. The whole `bin\` folder is the application — nothing else is required.

## What's inside (all verified)

- **Audio:** `libfdk_aac`, **`libfdk_xhe_aac`** (xHE-AAC), opus, mp3lame, vorbis, theora, amr-nb/wb, gsm, lc3, shine, speex, soxr (OpenMP), bs2b, flite, rubberband, mysofa, chromaprint
- **Video:** x264, x265, VP8/9 (libvpx), AV1 (aom / rav1e / SVT-AV1), vvenc, webp, xvid, openjpeg, snappy/lzma/bz2/zlib
- **GPU:** NVENC/NVDEC/CUVID (`h264/hevc/av1_nvenc`, sm_75/89/120), CUDA hwaccel, AMF, QSV (libvpl), D3D11VA/D3D12VA/DXVA2, VAAPI
- **Subtitles/text:** fontconfig + freetype + harfbuzz + fribidi + libass (`drawtext`, `subtitles`), frei0r, aribb24/aribcaption
- **Discs/capture:** libcdio (CD-ROM), dvdnav/dvdread, bluray, avisynth, vapoursynth(-free), opengl-free SDL2 ffplay, openal, mediafoundation
- **Network/IO:** gnutls, libcurl, libsrt, librist, libssh, libzmq, librabbitmq, gmp
- **Misc:** gme/modplug/openmpt chiptune+modules, zvbi, vidstab, zimg (no OCIO — static), jxl, lensfun-free set, libvmaf

## Quirks & known issues

1. **It's 176 MB on purpose.** Every library (debug-free but unstripped, static archives pull whole object sets) lives inside one binary. `ldd` shows only `ntdll/kernel32/...` — that's the point.

2. **Fontconfig still needs `FONTCONFIG_FILE`** even though the lib is compiled in: the conf file itself (`C:\msys64\ucrt64\etc\fonts\fonts.conf`) lives on disk. The `.cmd` wrappers set it. If you deploy this exe to a machine without MSYS2, ship a small `fonts.conf` next to it and point the env var at it (or just drop the `drawtext`/ass use cases).

3. **The 10 DLL-only libraries are NOT here** — whisper, codec2, iLBC, qrencode, xevd/xeve (EVC), vulkan, OpenCL, libplacebo, OpenColorIO. MSYS2 ships them DLL-only (no static archive), and GNU `ld -static` refuses `.dll.a` import libs entirely — those are the exact libs the dynamic build exists for. (You dropped vulkan/OpenCL on purpose for this one: CUDA-only.)

4. **9 more libs missing** — `oapv, astcenc, davs2, lensfun, lcevc-dec, quirc, svtjpegxs, uavs3d, xavs2` packages aren't installed (same list the dynamic build skipped).

5. **Rebuilding is fussy — don't just re-run configure.** The static link depends on the recipe in `H:\vscode\ffmpeg\build\` (hide all `.dll.a`, `-static` + 25 `-D*_STATIC` macros, the `libhwy_imp.a` shim, the objcopy-renamed `sha1_init` in `libssh.a`, patched `.pc` files, the `common.mak` windres fix, the aribcc static header define). `build-static.sh` runs all of it and auto-`distclean`s if the tree was left configured for the dynamic build. **Never run a static and dynamic build at the same time** — they share `H:\vscode\ffmpeg\FFmpeg`.

6. **windres needs a console** — `build-static.sh` handles it via a hidden PowerShell window (`build\windres-fftoolsres.ps1`). If you ever rebuild manually and `fftoolsres.o` fails with "Bad file descriptor", that's why.

## Examples

```
examples\run-all.cmd              ← everything
01-basic-encode.cmd   NVENC h264 + FDK AAC + fontconfig drawtext (the flagship chain)
02-codec-tour.cmd     x265, SVT-AV1, rav1e, opus, mp3lame quick encodes
03-hw-decode.cmd      d3d11va hardware decode of a real h264 file
04-chromaprint.cmd    audio fingerprinting (AcoustID-format)
05-feature-check.cmd  buildconf / hwaccel / protocol inventory (proves the lib set)
```

## Verifying the "100% static" claim yourself

In MSYS2: `ldd /h/vscode/ffmpeg/out/bin/ffmpeg.exe` → only `ntdll`, `kernel32`, `msvcrt`-family Windows entries, nothing from `/ucrt64`. Or from a bare `cmd`: `set PATH=C:\Windows\system32;C:\Windows&& H:\vscode\ffmpeg\out\bin\ffmpeg.exe -version` still works — no MSYS2 involved.
