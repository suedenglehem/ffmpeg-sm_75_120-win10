@echo off
setlocal
cd /d %~dp0
if not exist out mkdir out
set FFM=%~dp0..\out\bin\ffmpeg.cmd

echo [09] whisper speech-to-text
echo.
echo The whisper filter needs a whisper.cpp model file - NOT shipped.
echo Grab one (drop it in examples\out\ as ggml-base.en.bin):
echo   https://huggingface.co/ggerganov/whisper/tree/main
echo   ggml-tiny.bin (75 MB, fastest) / ggml-base.en.bin (142 MB, English)
echo.
if not exist out\ggml-base.en.bin (
  echo   [SKIP] no model file at examples\out\ggml-base.en.bin yet
  echo   Template command once a model is present:
  echo     ..\out\bin\ffmpeg.cmd -i input.mp4 -af whisper=model=out\ggml-base.en.bin:destination=out\transcript.txt -f null -
  goto :eof
)
call %FFM% -hide_banner -v error -f lavfi -i sine=frequency=440:duration=3 -af whisper=model=out\ggml-base.en.bin:destination=out\transcript.txt -f null -
if %ERRORLEVEL% NEQ 0 (echo   [FAIL] whisper filter) else (echo   [PASS] whisper filter ran, see out\transcript.txt)
pause
