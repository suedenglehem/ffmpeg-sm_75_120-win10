# FFmpeg Dynamic Build — `fdk-cuda75-120-dynamic`

Windows 64-bit build from git master (`N-129186-g47f7313e6a`), built 2026-11-22 with **every installable MSYS2 UCRT64 library enabled** — including the 10 DLL-only libraries that the 100%-static build (`H:\vscode\ffmpeg\out`) had to drop.

| Build | Location | Character |
|---|---|---|
| **Static** | `H:\vscode\ffmpeg\out\bin` | one 176 MB exe, zero third-party DLLs, CUDA/NVENC only, **no** whisper/codec2/ilbc/qrencode/EVC/vulkan/opencl/placebo/opencolorio |
| **Dynamic** (this) | `H:\vscode\ffmpeg\dynamic\out\bin` | 57 MB exes + bundled DLLs, **everything enabled** (120+ libs) |

## Folder layout

```
dynamic\
├─ README.md                 ← this file
├─ configure-dynamic.sh      ← build scripts (re-runnable)
├─ build-dynamic.sh          ← configure loop + make + install
├─ configure.log / make.log / build-dynamic.log
├─ examples\                 ← runnable test scripts (see below)
│  └─ run-all.cmd            ← runs everything, prints PASS/FAIL
└─ out\bin\
   ├─ ffmpeg.exe / ffprobe.exe / ffplay.exe
   ├─ 137 bundled .dll files
   └─ ffmpeg.cmd / ffprobe.cmd / ffplay.cmd   ← always use THESE
```

## How to run

**Use the `.cmd` wrappers** (`ffmpeg.cmd`, `ffprobe.cmd`, `ffplay.cmd`) — they set `FONTCONFIG_FILE` so `drawtext`/subtitles find fonts. Plain `ffmpeg.exe` works too, but prints fontconfig warnings and can't look up fonts in a bare Windows shell.

- Keep the exes **together with the bundled DLLs** — they load them from their own folder. No MSYS2 needed in `PATH`.
- `vulkan-1.dll` and `OpenCL.dll` come from your GPU driver (Windows system files) — that's by design; the bundled loader stubs are not used.

## What this build adds over the static one (all verified working)

| Library | What you get | Quick test |
|---|---|---|
| **whisper** | `whisper` audio filter — speech→text (whisper.cpp/ggml) | needs a model file, see `examples\09-whisper.cmd` |
| **codec2** | `libcodec2` encoder+decoder (amateur radio voice codecs) | `ffmpeg -f lavfi -i sine=duration=1 -c:a libcodec2 -b:a 8k out.c2` |
| **iLBC** | `libilbc` decoder | `ffmpeg -i in.wav -c:a libilbc -b:a 15k out.ilbc` (native enc + wrapper dec) |
| **qrencode** | `qrencode` vf (draw QR over video) + `qrencodesrc` source | `ffmpeg -f lavfi -i qrencodesrc=text=HI:q=256 -frames:v 1 qr.png` |
| **xeve** | `libxeve` — EVC / MPEG-5 video **encoder** | **must pass `-tune zerolatency`** (see Quirk 1) |
| **xevd** | `libxevd` — EVC **decoder** | see Quirk 2 (upstream stall) |
| **vulkan** | `vulkan` hwaccel + `_vulkan` filter family (`scale_vulkan`, `avgblur_vulkan`, …) | `examples\05-vulkan.cmd` |
| **opencl** | `opencl` hwaccel + `_opencl` filter family | hwaccel listed; needs an OpenCL ICD (see Quirk 3) |
| **libplacebo** | `libplacebo` / `libplacebo_scene` filters (tonemapping, upscale, GPU compositing) | `examples\06-libplacebo.cmd` |
| **opencolorio** | color-management backend for `zscale` (via libzimg) | `examples\07-zscale-ocio.cmd` |

Everything the static build has is here too: `libfdk_aac`/`libfdk_xhe_aac`, NVENC/NVDEC (sm_75/89/120), fontconfig drawtext, `srt/rist/ssh/zmq/rabbitmq` networking, `cdio/dvdnav/bluray` discs, `x264/x265/vpx/aom/rav1e/svt-av1/opus/mp3lame/…`, `ass/drawtext/frei0r/lensfun-free` filtering, `amf/d3d11va/d3d12va/qsv/vaapi/cuda` hwaccels.

## Quirks & known issues

1. **`libxeve` emits 0 frames with its default preset.** No error — just "Output file is empty". Always add **`-tune zerolatency`**:
   `ffmpeg -i in.mp4 -c:v libxeve -tune zerolatency out.evc`
   (Upstream lookahead/flush bug, not a build defect. `-preset fast`/`-profile main` also work.)

2. **`libxevd` decode can stall.** It decodes ~2 frames of a short clip, then grinds to ~0.001x and may never reach EOF. Upstream xevd bug. Safe pattern for spot-checks: `-threads 1 -frames:v 1`. Decode a few frames, not whole files. (FFmpeg's native `evc` decoder/demuxer also exists for reference.)

3. **OpenCL finds no device on this machine.** `init_hw_device opencl` returns `-19` — the only `OpenCL.dll` present is the Windows loader stub and no vendor ICD registers an OpenCL platform (common on CUDA-only setups). The build supports it; the machine doesn't. You're CUDA-only anyway, so the CUDA hwaccel path (`-hwaccel cuda`) is the one to use.

4. **Vulkan: prefer `hwupload`.** `format=vulkan` straight after a CPU source fails format negotiation ("Invalid argument"). The verified path is:
   `ffmpeg -init_hw_device vulkan -i in.mp4 -vf hwupload,...,hwdownload -f null -`
   Device creation itself works; NVIDIA's ICD is used.

5. **Fontconfig needs `FONTCONFIG_FILE`.** A bare Windows shell has no idea where the msys conf lives, so `drawtext` errors. The `.cmd` wrappers set it to `C:\msys64\ucrt64\etc\fonts\fonts.conf` (which reads the MSYS2 font dirs — and Windows fonts via `C:\Windows\Fonts` if installed there). Copy the whole `bin\` folder and update the wrapper paths if you move it.

6. **Filter names:** the QR filters are **`qrencode`** (video overlay) and **`qrencodesrc`** (source) — not "qrcode". And their size option is `q=` / `qrcode_width=`.

7. **whisper needs a model + `destination`.** The filter loads a whisper.cpp `.bin` model (~40–150 MB, e.g. `ggml-base.en.bin` from the whisper.cpp models on Hugging Face) and writes the transcript via `destination=path.txt`:
   `ffmpeg -i in.mp4 -af whisper=model=ggml-base.en.bin:destination=transcript.txt -f null -`

8. **opencolorio has no own filter.** It powers `zscale` color management through libzimg. Pass full color params (zimg refuses to guess): see `examples\07-zscale-ocio.cmd`.

9. **9 libraries are NOT in this build** because the packages aren't installed: `oapv, astcenc, davs2, lensfun, lcevc-dec, quirc, svtjpegxs, uavs3d, xavs2` (the configure loop dropped them automatically, all logged in `build-dynamic.log`).

## Examples

Double-click or run from cmd — each prints `[PASS]`/`[FAIL]` and writes outputs to `examples\out\`:

```
examples\run-all.cmd              ← everything
01-basic-encode.cmd   NVENC h264 + FDK AAC + fontconfig drawtext (the flagship chain)
02-codec2.cmd         codec2 encode → decode roundtrip
03-qrencode.cmd       QR code source + overlay render
04-evc-xeve.cmd       EVC encode (zerolatency workaround) + safe xevd spot-check
05-vulkan.cmd         Vulkan device + hwupload GPU path
06-libplacebo.cmd     libplacebo tonemap filter
07-zscale-ocio.cmd    zscale color pipeline (opencolorio-backed zimg)
08-opencl-info.cmd    hwaccel inventory + documents the no-ICD situation
09-whisper.cmd        speech→text template (drop a model file in first)
```

## Rebuilding

```
bash /h/vscode/ffmpeg/dynamic/build-dynamic.sh
```
Auto-distcleans if the tree was left in static config, flips the aribcc header to SHARED for the build and restores the static patch on exit (trap), runs the configure degradation loop (never drops FDK), prebuilds the `.rc` object via console-hosted windres, makes, installs. If the shared FFmpeg tree is later reconfigured for the static build (`build-static.sh`), it now auto-distcleans the dynamic tree too — but don't run the two builds simultaneously; they share `H:\vscode\ffmpeg\FFmpeg`.
