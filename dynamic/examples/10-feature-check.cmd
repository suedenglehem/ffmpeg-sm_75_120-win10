@echo off
setlocal
cd /d %~dp0
set FFM=%~dp0..\out\bin\ffmpeg.cmd

echo [10] Verify the 10 dynamic-only libs are compiled in
call %FFM% -hide_banner -buildconf | findstr /i "enable-whisper enable-libcodec2 enable-libilbc enable-libqrencode enable-libxevd enable-libxeve enable-vulkan enable-opencl enable-libplacebo enable-libopencolorio"
echo   (all ten must appear above)
echo.
echo Plus the static-build staples:
call %FFM% -hide_banner -buildconf | findstr /i "enable-libfdk-aac enable-libfdk-xhe-aac enable-nvenc enable-nvdec enable-fontconfig enable-libcdio"
echo.
pause
