@echo off
setlocal
cd /d %~dp0
echo ================================================================
echo  Static FFmpeg test suite - outputs in examples\out\
echo ================================================================
echo.
call "%~dp001-basic-encode.cmd" <nul
call "%~dp002-codec-tour.cmd" <nul
call "%~dp003-hw-decode.cmd" <nul
call "%~dp004-chromaprint.cmd" <nul
call "%~dp005-feature-check.cmd" <nul
echo.
echo All examples finished. Review PASS/FAIL above.
pause
