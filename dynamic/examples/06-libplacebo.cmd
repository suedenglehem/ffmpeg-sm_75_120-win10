@echo off
setlocal
cd /d %~dp0
if not exist out mkdir out
set FFM=%~dp0..\out\bin\ffmpeg.cmd

echo [06] libplacebo tonemap filter (creates its own vulkan device internally)
call %FFM% -hide_banner -v warning -f lavfi -i testsrc2=size=320x180:rate=10:duration=1 -vf "libplacebo=tonemapping=bt.2390:format=yuv420p" -f null -
if %ERRORLEVEL% NEQ 0 (echo   [FAIL] libplacebo) else (echo   [PASS] libplacebo)

echo.
echo Also available: libplacebo_scene (GPU compositing of several inputs).
echo On a real HDR file: ffmpeg -i hdr.mkv -vf "libplacebo=tonemapping=bt.2390:colorspace=bt709:color_primaries=bt709:color_trc=bt709:format=yuv420p" -c:a copy out.mp4
echo.
pause
