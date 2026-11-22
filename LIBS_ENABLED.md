# Libraries enabled — static vs dynamic

Source of truth: `ffmpeg.exe -version` configuration line of each build
(`out\bin\ffmpeg.exe` = static, `dynamic\out\bin\ffmpeg.exe` = dynamic).
The static build's line ends with a `--disable-*` tail: the 19 DLL-only
libraries listed in the last table — that's the exact difference between the two builds.

## STATIC build (`fdk-cuda75-120`) — 100% static, zero DLLs

| Library enabled | What it's for |
|---|---|
| libfdk-aac | Fraunhofer AAC encoder — top-quality AAC |
| libfdk-xhe-aac | xHE-AAC: high-efficiency AAC + loudness (streaming radio) |
| libmp3lame | MP3 encoder |
| libshine | fixed-point MP3 encoder (low-power) |
| libtwolame | MPEG Layer-2 (MP2) encoder |
| libopus | Opus audio encode/decode |
| libvorbis | Ogg Vorbis audio |
| libtheora | Theora video encoder |
| libspeex | Speex speech codec |
| libgsm | GSM full-rate speech codec |
| liblc3 | LC3 codec (Bluetooth LE Audio) |
| libopencore-amrnb | AMR-NB narrowband speech (3G voice) |
| libopencore-amrwb | AMR-WB wideband speech decode |
| libvo-amrwbenc | AMR-WB wideband speech encode |
| libgme | chiptune / game music formats (GME) |
| libmodplug | tracked MOD music playback |
| libopenmpt | modern MOD/tracker music playback |
| libbs2b | Bauerle stereophonic virtualizer (BS2B filter) |
| libflite | text-to-speech (flite filter) |
| libmysofa | SOFA acoustic impulse responses (spatial audio) |
| librubberband | time-stretch / pitch-shift without quality loss |
| libsoxr | high-quality audio resampling |
| chromaprint | audio fingerprinting (fpcalc/Chromaprint muxer) |
| openal | 3D positional audio output (ffplay) |
| ladspa | LADSPA audio effect plugin host |
| libx264 | H.264/AVC encoder |
| libx265 | HEVC/H.265 encoder |
| libxvid | MPEG-4 Part 2 (XviD) encoder |
| libaom | AV1 reference encoder |
| libdav1d | fast AV1 decoder |
| libsvtav1 | AV1 encoder (Intel SVT — fast) |
| librav1e | AV1 encoder (Rust — quality) |
| libvpx | VP8/VP9 codec |
| libvvenc | H.266/VVC encoder |
| libjxl | JPEG XL image codec |
| libopenjpeg | JPEG-2000 encode/decode |
| libwebp | WebP images |
| libvmaf | Netflix VMAF quality metric filter |
| libvidstab | 3D video stabilization filter |
| libzimg | high-quality scaling & color-space conversion (zscale) |
| nvenc | NVIDIA hardware H.264/HEVC/AV1 encode (sm_75/89/120) |
| nvdec | NVIDIA hardware decode |
| cuvid | NVIDIA CUVID legacy decoder API |
| ffnvcodec | NVIDIA NVCodec headers (NVENC/NVDEC API defs) |
| libnpp | NVIDIA NPP GPU image processing (scale_npp) |
| amf | AMD AMF hardware encode/decode |
| libvpl | Intel oneAPI VPL (Quick Sync, incl. AV1) |
| d3d11va | Direct3D 11 hardware decode |
| d3d12va | Direct3D 12 hardware decode |
| dxva2 | DXVA (D3D9-era) hardware decode |
| mediafoundation | Windows MediaFoundation capture/encode |
| vaapi | VA-API hardware (Linux path; present in build) |
| libass | SSA/ASS subtitle rendering (subtitles filter) |
| libfreetype | font glyph rendering (drawtext) |
| libharfbuzz | text shaping (ligatures/kerning for drawtext) |
| libfribidi | bidirectional (RTL) text layout |
| fontconfig | system font lookup for drawtext/libass |
| cairo | vector drawing backend (overlay rendering) |
| libaribb24 | ARIB-B24 teletext decoding (JP broadcast) |
| libaribcaption | ARIB STD-B24 caption rendering |
| libzvbi | teletext/VBI stream decoding |
| frei0r | frei0r plugin video filters |
| libcurl | http/https/ftp(s) protocols |
| gnutls | TLS backend (https, rtmps) |
| libsrt | SRT protocol (secure reliable transport) |
| librist | RIST protocol (reliable streaming) |
| libzmq | ZeroMQ protocol (zmq: URLs) |
| librabbitmq | AMQP/RabbitMQ protocol (amqp: URLs) |
| libssh | SSH/SFTP protocol (sftp: URLs) |
| libbluray | Blu-ray disc navigation/reading |
| libdvdnav | DVD navigation (menus) |
| libdvdread | DVD video reading |
| libcdio | CD-DA audio disc reading (cd: protocol) |
| avisynth | AviSynth/AviSynth+ script as input |
| vapoursynth | VapourSynth script as input |
| sdl2 | ffplay audio/video output backend |
| libcaca | ASCII-art video output |
| libxml2 | XML parsing (DASH, ffmetadata, profiles) |
| iconv | charset conversion (subtitles, metadata) |
| lcms2 | ICC color-profile management |
| gmp | multiple-precision math (optional crypto/format paths) |
| zlib | deflate compression (stream/metadata compression) |
| bzlib | bzip2 decompression support |
| lzma | LZMA/xz decompression support |
| libsnappy | Snappy compression support |
| pthreads | POSIX threading backend (not a lib) |
| gpl / version3 / nonfree | license flags (not libs) |

## DYNAMIC build (`fdk-cuda75-120-dynamic`) — everything above, **plus** these 19

| Library enabled | What it's for |
|---|---|
| whisper | OpenAI Whisper speech recognition → subtitles (`whisper` filter) |
| libcodec2 | Codec2 narrow-band digital voice (amateur radio) |
| libilbc | iLBC internet low-bitrate speech codec |
| libqrencode | QR-code **generation** (`qrencode`, `qrencodesrc` filters) |
| libquirc | QR-code **detection/decoding** (from video) |
| libxeve | EVC (H.266-family) encoder — needs `-tune zerolatency` |
| libxevd | EVC decoder — use `-threads 1 -frames:v 1` (stall bug) |
| libdavs2 | AVS2 decoder (Chinese broadcast standard) |
| libxavs2 | AVS2 encoder |
| libuavs3d | AVS3 decoder (next-gen Chinese standard) |
| liboapv | OAPV advanced picture/video codec |
| libsvtjpegxs | JPEG XS light-compression (SMPTE 2110-22 broadcast) |
| libastcenc | ASTC adaptive texture compression (GPU textures) |
| liblcevc-dec | LCEVC enhancement layer decoder (resolution boosting) |
| liblensfun | photographic lens distortion/color-correction filter |
| vulkan | Vulkan GPU compute (hwupload, vulkan filters) |
| opencl | OpenCL GPU compute (opencl filters; needs an ICD) |
| libplacebo | GPU video rendering: HDR tonemapping, high-quality upscale (Vulkan) |
| libopencolorio | ACES/OCIO color management (zscale backend via libzimg) |

Check anytime with:

```
ffmpeg.exe -hide_banner -version          ← configuration line
ffmpeg.exe -hide_banner -buildconf        ← same, formatted
```
