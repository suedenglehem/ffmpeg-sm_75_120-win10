@echo off
setlocal
cd /d %~dp0
if not exist out mkdir out
set FFM=%~dp0..\bin\ffmpeg.cmd

echo [02] Static codec tour - each encoder is baked into the one exe
call %FFM% -hide_banner -v error -f lavfi -i testsrc2=size=128x72:rate=10:duration=0.5 -c:v libx265 -preset ultrafast -x265-params log-level=error -y out\t.mp4
if %ERRORLEVEL% NEQ 0 (echo   [FAIL] x265) else (echo   [PASS] x265 / HEVC)

call %FFM% -hide_banner -v error -f lavfi -i testsrc2=size=128x72:rate=10:duration=0.5 -c:v libsvtav1 -preset 12 -y out\t.mkv
if %ERRORLEVEL% NEQ 0 (echo   [FAIL] SVT-AV1) else (echo   [PASS] SVT-AV1 - note: use .mkv, there is no .av1 muxer)

call %FFM% -hide_banner -v error -f lavfi -i testsrc2=size=128x72:rate=10:duration=0.5 -c:v librav1e -speed 10 -y out\t2.ivf
if %ERRORLEVEL% NEQ 0 (echo   [FAIL] rav1e) else (echo   [PASS] rav1e / AV1)

call %FFM% -hide_banner -v error -f lavfi -i sine=frequency=440:duration=1 -c:a libopus -y out\t.opus
if %ERRORLEVEL% NEQ 0 (echo   [FAIL] opus) else (echo   [PASS] opus)

call %FFM% -hide_banner -v error -f lavfi -i sine=frequency=440:duration=1 -c:a libmp3lame -q:a 4 -y out\t.mp3
if %ERRORLEVEL% NEQ 0 (echo   [FAIL] mp3lame) else (echo   [PASS] mp3lame)

call %FFM% -hide_banner -v error -f lavfi -i sine=frequency=440:duration=1 -c:a libfdk_xhe_aac -b:a 48k -y out\t.m4a
if %ERRORLEVEL% NEQ 0 (echo   [FAIL] xHE-AAC) else (echo   [PASS] libfdk_xhe_aac)

echo.
echo Outputs in examples\out\
pause
