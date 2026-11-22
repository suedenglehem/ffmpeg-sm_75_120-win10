@echo off
setlocal
cd /d %~dp0
set FFM=%~dp0..\out\bin\ffmpeg.cmd

echo [07] zscale color pipeline (OpenColorIO-powered zimg)
echo Note: opencolorio has no filter of its own - it backs zscale via libzimg.
echo       zimg refuses to guess colorspaces, so pass full in/out params.
call %FFM% -hide_banner -v error -f lavfi -i color=c=red:s=16x16:d=0.1 -vf "zscale=primariesin=bt709:transferin=bt709:matrixin=bt709:primaries=bt709:transfer=linear:matrix=bt709" -frames:v 1 -f null -
if %ERRORLEVEL% NEQ 0 (echo   [FAIL] zscale) else (echo   [PASS] zscale bt709 ^-^> linear transfer)

echo.
echo Practical HDR-10 to SDR example:
echo   ffmpeg -i hdr.mp4 -vf "zscale=primariesin=bt2020:transferin=pq:matrixin=bt709:primaries=bt709:transfer=bt709:matrix=bt709" -c:a copy out.mp4
echo.
pause
