@echo off
setlocal
cd /d %~dp0
set FFM=%~dp0..\out\bin\ffmpeg.cmd

echo [08] OpenCL inventory (this machine has NO OpenCL platform - expected)
echo.
echo HWACCELS compiled in (opencl IS compiled in):
call %FFM% -hide_banner -hwaccels
echo.
echo Trying init_hw_device opencl - on this machine this FAILS with -19 /
echo "no such device" because only the Windows loader stub OpenCL.dll exists
echo and no vendor ICD (NVIDIA/AMD/Intel OpenCL runtime) is installed.
echo The build is fine; the machine lacks the runtime. CUDA is the GPU path here.
call %FFM% -hide_banner -v error -init_hw_device opencl -f lavfi -i testsrc2=size=64x64:rate=10:duration=0.1 -vf format=opencl -f null - 2>nul
if %ERRORLEVEL% NEQ 0 (echo   [KNOWN] opencl device unavailable on this machine - as documented) else (echo   [PASS] opencl works - an ICD got installed since the notes were written)
echo.
pause
