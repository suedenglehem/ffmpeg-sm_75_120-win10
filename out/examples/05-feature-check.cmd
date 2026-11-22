@echo off
setlocal
cd /d %~dp0
set FFM=%~dp0..\bin\ffmpeg.cmd

echo [05] Static build inventory - proves the static lib set
echo.
echo Core libs compiled in:
call %FFM% -hide_banner -buildconf | findstr /i "enable-libfdk-aac enable-libfdk-xhe-aac enable-nvenc enable-nvdec enable-cuvid enable-fontconfig enable-libass enable-libcdio enable-libsrt enable-libssh enable-libzmq enable-libcurl enable-libbluray enable-libvvenc enable-librav1e enable-libsvtav1"
echo.
echo HWACCELS:
call %FFM% -hide_banner -hwaccels
echo.
echo Network protocols (srt/rist/ssh/zmq/rabbitmq/gnutls/rtmp via curl):
call %FFM% -hide_banner -protocols 2>nul | findstr /i "srt rtmp ssh zmq amqp gnutls"
echo.
echo NOT in this build (DLL-only libs - use the dynamic build):
echo   whisper, codec2, ilbc, qrencode, xevd, xeve, vulkan, opencl, placebo, opencolorio
echo.
pause
