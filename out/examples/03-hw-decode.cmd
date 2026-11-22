@echo off
setlocal
cd /d %~dp0
if not exist out mkdir out
set FFM=%~dp0..\bin\ffmpeg.cmd

echo [03] Hardware decode paths on this NVIDIA machine
echo Make sure a test file exists first:
if not exist out\hw-src.mp4 call %FFM% -hide_banner -v error -f lavfi -i testsrc2=size=640x360:rate=30:duration=2 -c:v h264_nvenc -preset p1 -y out\hw-src.mp4

echo d3d11va decode:
call %FFM% -hide_banner -v error -hwaccel d3d11va -i out\hw-src.mp4 -f null -
if %ERRORLEVEL% NEQ 0 (echo   [FAIL] d3d11va) else (echo   [PASS] d3d11va)

echo cuda (NVDEC) decode:
call %FFM% -hide_banner -v error -hwaccel cuda -i out\hw-src.mp4 -f null -
if %ERRORLEVEL% NEQ 0 (echo   [FAIL] cuda) else (echo   [PASS] cuda / NVDEC)

echo.
echo Also available: dxva2, d3d12va, qsv, vaapi, amf - see: ffmpeg -hwaccels
pause
