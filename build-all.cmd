@echo off
REM Master build launcher - runs the static build, then the dynamic build.
REM Requires MSYS2 at C:\msys64. Log lives in build-all.log next to this file.
if not exist C:\msys64\usr\bin\bash.exe (
  echo MSYS2 not found at C:\msys64 - install it and add the UCRT64 toolchain.
  pause
  exit /b 1
)
set LOG=%~dp0build-all.log
echo Running master build (static then dynamic), logging to %LOG%
C:\msys64\usr\bin\bash.exe -lc "export MSYSTEM=UCRT64 PATH=/ucrt64/bin:/usr/bin:/bin; /h/vscode/ffmpeg/build-all.sh 2>&1 | tee /h/vscode/ffmpeg/build-all.log"
echo.
echo Finished. Full log: %LOG%
pause
