@echo off
setlocal
cd /d %~dp0
if not exist out mkdir out
set FFM=%~dp0..\out\bin\ffmpeg.cmd

echo [05] Vulkan GPU path (device + hwupload + back)
echo Note: use hwupload; plain "format=vulkan" after a CPU source fails negotiation.
call %FFM% -hide_banner -v error -init_hw_device vulkan -f lavfi -i testsrc2=size=128x128:rate=10:duration=1 -vf hwupload -f null -
if %ERRORLEVEL% NEQ 0 (echo   [FAIL] vulkan device + hwupload) else (echo   [PASS] vulkan device + hwupload)

echo.
echo Extra _vulkan filters available: scale_vulkan, avgblur_vulkan, bwdif_vulkan,
echo chromaber_vulkan, overlay_vulkan, blend_vulkan, drawbox_vulkan, ...
echo (each needs frames already on the vulkan device via hwupload)
echo.
pause
