@echo off
setlocal
cd /d %~dp0
if not exist out mkdir out
set FFM=%~dp0..\out\bin\ffmpeg.cmd
set FFPR=%~dp0..\out\bin\ffprobe.cmd

echo [02] codec2 encode / decode roundtrip
call %FFM% -hide_banner -v error -f lavfi -i sine=frequency=440:duration=2 -c:a libcodec2 -b:a 8k -y out\voice.c2
if %ERRORLEVEL% NEQ 0 (echo   [FAIL] codec2 encode) else (echo   [PASS] codec2 encode)

call %FFPR% -hide_banner -v error -show_entries stream=codec_name -of csv=p=0 out\voice.c2
echo   (expect: codec2)

call %FFM% -hide_banner -v error -i out\voice.c2 -y out\voice-back.wav
if %ERRORLEVEL% NEQ 0 (echo   [FAIL] codec2 decode) else (echo   [PASS] codec2 decode)

echo.
echo Note: codec2 modes by bitrate: 700/1400/1600/2400/3200/6400 bps etc.
echo Done. Outputs: examples\out\voice.c2, voice-back.wav
pause
