@echo off
setlocal
cd /d %~dp0
if not exist out mkdir out
set FFM=%~dp0..\out\bin\ffmpeg.cmd
set FFPR=%~dp0..\out\bin\ffprobe.cmd

echo [04] EVC encode (libxeve) + safe decode (libxevd)
echo QUIRK: libxeve with DEFAULT preset produces an empty file (upstream flush bug).
echo        ALWAYS pass -tune zerolatency.
call %FFM% -hide_banner -v error -f lavfi -i testsrc2=size=320x192:rate=10:duration=2 -tune zerolatency -c:v libxeve -y out\clip.evc
if %ERRORLEVEL% NEQ 0 (echo   [FAIL] xeve encode) else (echo   [PASS] xeve encode)

call %FFPR% -hide_banner -v error -show_entries stream=codec_name,width,height -of csv=p=0 out\clip.evc
echo   (expect: evc,320,192)

echo.
echo QUIRK: libxevd decode can stall after a couple of frames (upstream bug).
echo        Safe spot-check pattern: -threads 1 -frames:v 1
call %FFM% -hide_banner -v error -threads 1 -i out\clip.evc -frames:v 1 -f null -
if %ERRORLEVEL% NEQ 0 (echo   [FAIL] xevd decode) else (echo   [PASS] xevd decode ^(1 frame, 1 thread^))

echo.
echo Outputs: examples\out\clip.evc
pause
