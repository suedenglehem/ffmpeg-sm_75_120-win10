@echo off
setlocal
cd /d %~dp0
if not exist out mkdir out
set FFM=%~dp0..\out\bin\ffmpeg.cmd

echo [03] qrencode: QR source + QR overlay
echo Note: filters are named qrencode / qrencodesrc (NOT qrcode); size option is q=
call %FFM% -hide_banner -v error -f lavfi -i qrencodesrc=text=FFMPEG-DYNAMIC:q=256 -frames:v 1 -y out\qr-source.png
if %ERRORLEVEL% NEQ 0 (echo   [FAIL] qrencodesrc) else (echo   [PASS] qrencodesrc)

call %FFM% -hide_banner -v error -f lavfi -i testsrc2=size=320x320:rate=10:duration=0.3 -vf qrencode=text=HELLO:q=128 -frames:v 1 -y out\qr-overlay.png
if %ERRORLEVEL% NEQ 0 (echo   [FAIL] qrencode overlay) else (echo   [PASS] qrencode overlay)

echo.
echo Done. Outputs: examples\out\qr-source.png, qr-overlay.png
pause
