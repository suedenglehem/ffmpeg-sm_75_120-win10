@echo off
setlocal
cd /d %~dp0
if not exist out mkdir out
set FFM=%~dp0..\bin\ffmpeg.cmd

echo [04] chromaprint audio fingerprinting (AcoustID/MusicBrainz format)
if not exist out\fp-src.mp4 call %FFM% -hide_banner -v error -f lavfi -i sine=frequency=440:duration=3 -c:a libfdk_aac -y out\fp-src.mp4

call %FFM% -hide_banner -v error -i out\fp-src.mp4 -f chromaprint -fp_format base64 out\fingerprint.txt
if %ERRORLEVEL% NEQ 0 (echo   [FAIL] chromaprint) else (echo   [PASS] chromaprint)

set /p FPRINT=<out\fingerprint.txt
echo   fingerprint: %FPRINT:~0,64%...
echo.
echo Full fingerprint in examples\out\fingerprint.txt - uploadable to AcoustID.
pause
