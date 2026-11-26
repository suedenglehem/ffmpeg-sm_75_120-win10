# FFmpeg Windows builds — `H:\vscode\ffmpeg`

Repo: **github.com/suedenglehem/ffmpeg-sm_75_120-win10** (source `FFmpeg/` = FFmpeg git master checkout; everything else are the build recipes + logs). Two products, both built on this box under **MSYS2 UCRT64** (`C:\msys64`), CUDA 12.8 at `C:\cuda128`, MSVC 2022 (`cl.exe` as nvcc's host compiler).

| product | recipe | prefix | release tag / asset |
|---|---|---|---|
| **dynamic** (DLL deps, whisper/placebo/vulkan…) | `dynamic/configure-dynamic.sh` + `dynamic/build-dynamic.sh` | `dynamic/out` | `dynamic-fdk-cuda75-ptx` / `FFmpeg-fdk-cuda75-ptx-dynamic-win64.zip` |
| **static** (100 % static, only system DLLs) | `build/configure-ffmpeg.sh` via `build/build-static.sh` → `build/build-ffmpeg.sh` | `out` | `static-fdk-cuda75-ptx` / `FFmpeg-fdk-cuda75-ptx-static-win64.zip` |

The old `…-fdk-cuda75-120` releases (2026-11-22) were built with a **broken CUDA recipe: zero `*_cuda` filters shipped** (details below). They were **deleted on 2026-11-26** (user: "i don't need old releases, you can wipe them out") — the repo had no releases until the `ptx`-suffixed ones below ship. The `ptx` artifacts are the fixed ones; version strings say `fdk-cuda75-ptx[-dynamic|-static]`.

## How to build

```sh
# DYNAMIC — from a Git-Bash / any shell, it self-manages its environment:
/c/msys64/usr/bin/bash.exe -lc '/h/vscode/ffmpeg/dynamic/build-dynamic.sh > /h/vscode/ffmpeg/dynamic/rebuild-cuda-filters.log 2>&1'

# STATIC — hides *.dll.a import libs, distclean if a dynamic config is in
# the tree, configures+builds -static, restores the import libs on exit:
/c/msys64/usr/bin/bash.exe -lc '/h/vscode/ffmpeg/build/build-static.sh > /h/vscode/ffmpeg/build/run-static.log 2>&1'
```

- **NEVER run two builds at once** in `FFmpeg/` (shared tree): the two
  configures race and die with the fake "gcc is unable to create an
  executable file". Wait for one to finish; `build-static.sh` distcleans
  itself when a dynamic config is present (and vice versa — the dynamic
  driver distcleans on a `-static` config). A full-tree switch costs a
  ~1–1.5 h rebuild.
- The drivers run `configure` with a **graceful-degradation loop**: each
  `ERROR: <lib> not found` round appends `--disable-<opt>` and retries
  (optional libs are genuinely absent on fresh boxes). **FDK and nvcc are
  never degraded** — an nvcc failure aborts loudly (a silent
  `--disable-cuda-nvcc` is exactly how the filters vanished in 2025).
- windres needs a console: the drivers prebuild `fftoolsres.o` via
  `build/windres-fftoolsres.ps1` (hidden PowerShell window).

## The CUDA filters — why they kept silently disappearing (2026-11-26)

`--enable-cuda-nvcc` makes configure run `check_nvcc`, and the result
gates **all** `*_cuda` filters (`yadif_cuda`, `scale_cuda`,
`overlay_cuda`, `pad_cuda`, `transpose_cuda`, `bwdif_cuda`,
`colorspace_cuda`, `chromakey_cuda`, `bilateral_cuda`, `thumbnail_cuda`).
Nothing fails loudly when it goes wrong. Four independent killers, all
now fixed in the scripts (their headers carry the full story):

1. **`-ptx` forbids multiple `-gencode` archs.** `cuda_nvcc` appends
   `-ptx` to `nvccflags` **globally** (configure ~L7167 — it also lands
   in `ffbuild/config.mak` as `NVCCFLAGS`, which is what builds the real
   `vf_*.cuda.ptx` files: FFmpeg embeds the PTX *text* per filter and
   JITs it at load via `cuda/load_helper`). nvcc: `--ptx is not allowed
   when compiling for multiple GPU architectures`. So
   `--nvccflags` must be a **single pure-PTX gencode**:
   `-gencode arch=compute_75,code=compute_75 -O2`. compute_75 PTX is
   driver-JIT'd forward on Turing→Blackwell (the repo's sm_75_120 range;
   the box's 4080 SUPER / 4060 Ti at sm_89 run it through that JIT —
   verified live, 4K `scale_cuda` + `transpose_cuda`). The old
   `75,code=sm_75 + 89 + 120 + compute_120` SASS triple could **never**
   pass `check_nvcc` — that's why `fdk-cuda75-120` shipped no filters at
   all, despite the repo's name.
2. **`TMP`/`TEMP` unset → nvcc dies with rc=255 and NO output** ("failed
   checking for nvcc", empty log). Freshly-spawned bash (services, `-c`
   calls) often has none. Fix: `export TMP="$(cygpath -m /tmp)"`
   (Windows-style — the `cmd.exe` children need it).
3. **nvcc needs `cl.exe` AND `C:\Windows\system32` on PATH** (it spawns
   `cmd.exe` on Windows; `nvcc --version` works without them, every real
   compile dies at 255). The MSVC dir:
   `C:\Program Files\Microsoft Visual Studio\2022\Enterprise\VC\Tools\MSVC\*\bin\Hostx64\x64`
   (resolved by glob + `sort -V`). Needed at **configure AND make** time
   — the `.ptx` rules run under *make*'s env, so the env export must be
   in `build-dynamic.sh` / `build-ffmpeg.sh` too, not just the configure
   script.
4. **Comment lines inside the `./configure \` continuation**: backslash-
   newline joins them into the command, where `#` silently comments out
   **every remaining option** (`--nvcc`, `--nvccflags`, … vanish with no
   error). Keep recipe comments out of the continuation block.

Also: never run the configure script from a **Git-Bash** (tool shell) —
`/ucrt64` doesn't exist there, gcc isn't found, "C compiler test failed"
(looks like a broken toolchain, is just the wrong interpreter). Always
`/c/msys64/usr/bin/bash.exe [-lc]`.

## Verify a build has the filters (before shipping anything!)

```sh
out/bin/ffmpeg.exe -hide_banner -filters | grep -c _cuda   # 11 expected
# live GPU smoke (sm_89 box, PTX JIT):
out/bin/ffmpeg.exe -init_hw_device cuda=gpu:0 -filter_hw_device gpu \
  -f lavfi -i "color=c=black:s=3840x2160:r=60:d=1" \
  -vf "format=nv12,hwupload_cuda,scale_cuda=1920:1080:interp_algo=lanczos,transpose_cuda,hwdownload,format=nv12" \
  -frames:v 1 -f null -
out/bin/ffmpeg.exe -version | head -1   # must say fdk-cuda75-ptx[-dynamic|-static]
```

The dynamic build bundles its msys DLLs next to the exes (driver's last
step, `ldd`-driven) → the folder is self-contained; the static one needs
no DLLs at all (verify: `ldd out/bin/ffmpeg.exe` shows only system ones).

## Rebuild → release (gh CLI is logged in as suedenglehem)

```sh
# zip the whole bin/ dir (exes + bundled DLLs for the dynamic one)
cd /h/vscode/ffmpeg/dynamic/out && zip -r -q /tmp/FFmpeg-fdk-cuda75-ptx-dynamic-win64.zip bin
gh release create dynamic-fdk-cuda75-ptx \
  /tmp/FFmpeg-fdk-cuda75-ptx-dynamic-win64.zip \
  -R suedenglehem/ffmpeg-sm_75_120-win10 \
  -t "FFmpeg fdk-cuda75-ptx — dynamic bundle WITH CUDA filters (whisper, placebo, vulkan…)" \
  -n "Fixed CUDA recipe: single compute_75 PTX gencode + nvcc env fixes. The old fdk-cuda75-120 dynamic shipped ZERO *_cuda filters. 11 cuda filters incl. yadif/scale/overlay/pad/transpose_cuda."

# static: same shape, tag static-fdk-cuda75-ptx, zip from out/bin (no DLLs)
```

Keep tag/asset naming `…-ptx…` distinct from the old
`…-cuda75-120…` releases — never retag/push over the old ones; consumers
of the fass dist pick the new folder by name (`windows/FFmpeg-fdk-cuda75-ptx-*-win64`).

## fass dist hookup

The fass Windows dist bundles the **dynamic** build as
`H:\vscode\fass-win-cython\windows\FFmpeg-fdk-cuda75-*-win64\`;
`windows/serve.ps1` puts `windows\ffmpeg-*\bin` first on PATH. play2's
GPU variant (`fass/play2/sbs_hls_nvidia.ps1`, endpoint-picked) only runs
when the ffmpeg on PATH actually has the CUDA filters — that is this
build; the old dist folder silently fell back to the CPU twin
(libx264) because its build had none.
