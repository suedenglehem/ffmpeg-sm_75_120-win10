@echo off
setlocal
cd /d %~dp0
echo ================================================================
echo  Dynamic FFmpeg test suite - outputs in examples\out\
echo ================================================================
echo.
call "%~dp001-basic-encode.cmd" <nul
call "%~dp002-codec2.cmd" <nul
call "%~dp003-qrencode.cmd" <nul
call "%~dp004-evc-xeve.cmd" <nul
call "%~dp005-vulkan.cmd" <nul
call "%~dp006-libplacebo.cmd" <nul
call "%~dp007-zscale-ocio.cmd" <nul
call "%~dp008-opencl-info.cmd" <nul
call "%~dp009-whisper.cmd" <nul
call "%~dp010-feature-check.cmd" <nul
echo.
echo All examples finished. Review PASS/FAIL above.
pause
