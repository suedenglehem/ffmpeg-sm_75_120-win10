$cmd = '-lc "export MSYSTEM=UCRT64 PATH=/ucrt64/bin:/usr/bin:/bin; cd /h/vscode/ffmpeg/FFmpeg && /ucrt64/bin/windres.exe -I. -I./ -o fftools/fftoolsres.o fftools/fftoolsres.rc > /h/vscode/ffmpeg/build/windres-run.log 2>&1; echo RC=$? >> /h/vscode/ffmpeg/build/windres-run.log"'
Start-Process -FilePath 'C:\msys64\usr\bin\bash.exe' -ArgumentList $cmd -WindowStyle Hidden -Wait
if (Test-Path 'H:\vscode\ffmpeg\build\windres-run.log') {
  Get-Content 'H:\vscode\ffmpeg\build\windres-run.log'
} else {
  Write-Output "NO_LOG"
}
