# FFmpeg Windows Power-Build — static + dynamic, maxed-out library set

Two hand-tuned Windows 64-bit FFmpeg builds produced from **git master** on one MSYS2/CUDA machine:

| Build | Output | What it is |
|---|---|---|
| **STATIC** | `out\bin\ffmpeg.exe` (176 MB) | **100% static** — every library linked in, only Windows system DLLs at runtime. Copy one file anywhere. fdk-aac + **xHE-AAC**, NVENC/NVDEC (sm_75/89/120), ~110 libs, fontconfig, srt/ssh/zmq/disc-read. No vulkan/opencl/DLL-only libs. |
| **DYNAMIC** | `dynamic\out\bin\` (57 MB exes + DLLs) | **Everything enabled** (~120 libs): static's set **plus** whisper (speech→text), codec2, iLBC, qrencode, EVC encode/decode (xeve/xevd), vulkan, OpenCL, libplacebo, OpenColorIO. Ships self-contained with bundled DLLs. |

Both carry version `N-129186-g47f7313e6a-fdk-cuda75-ptx[-static|-dynamic]` and come with **runnable test suites** (`out\examples\run-all.cmd`, `dynamic\examples\run-all.cmd`) and dedicated READMEs with the full quirk lists. Every library enabled in each build, with what it's for: [`LIBS_ENABLED.md`](LIBS_ENABLED.md).

> **2026-11-26:** the `fdk-cuda75-120` builds shipped **zero `*_cuda` filters** — a broken nvcc recipe (multi-arch `-gencode` can never pass FFmpeg's `-ptx` check; details in [`ffmpeg.md`](ffmpeg.md)). Those releases were deleted; the `fdk-cuda75-ptx` builds below carry all 10 CUDA filters (yadif/scale/overlay/pad/transpose/bwdif/colorspace/thumbnail/chromakey/bilateral) as compute_75 PTX, driver-JIT'd forward on sm_75→Blackwell.

## Downloads

| Build | Release | Contents |
|---|---|---|
| Static (one-file) | [`static-fdk-cuda75-ptx`](https://github.com/suedenglehem/ffmpeg-sm_75_120-win10/releases/tag/static-fdk-cuda75-ptx) | `ffmpeg/ffprobe/ffplay.exe` + fontconfig `.cmd` wrappers (zip, ~197 MB) |
| Dynamic (everything) | [`dynamic-fdk-cuda75-ptx`](https://github.com/suedenglehem/ffmpeg-sm_75_120-win10/releases/tag/dynamic-fdk-cuda75-ptx) | `bin\` with exes + all DLLs, `examples\` test suite, README (zip, ~141 MB) |

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
