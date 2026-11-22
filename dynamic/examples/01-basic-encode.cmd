@echo off
setlocal
cd /d %~dp0
if not exist out mkdir out
set FFM=%~dp0..\out\bin\ffmpeg.cmd
set FFPR=%~dp0..\out\bin\ffprobe.cmd

echo [01] NVENC h264 + FDK AAC + fontconfig drawtext
call %FFM% -hide_banner -v error -f lavfi -i testsrc2=size=640x360:rate=30:duration=2 -f lavfi -i sine=frequency=440:duration=2 -vf "drawtext=text=DYNAMIC:fontsize=40:font='Arial'" -c:v h264_nvenc -preset p1 -c:a libfdk_aac -y out\basic.mp4
if %ERRORLEVEL% NEQ 0 (echo   [FAIL] encode) else (echo   [PASS] encode)

call %FFPR% -hide_banner -v error -show_entries stream=codec_name -of csv=p=0 out\basic.mp4
echo   (expect: h264 and aac)
echo.
echo Done. Output: examples\out\basic.mp4
pause
