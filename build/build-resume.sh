#!/bin/bash
# Resume make after pre-building fftoolsres.o (windres console workaround).
export MSYSTEM=UCRT64
export PATH=/ucrt64/bin:/usr/bin:/bin
B=/h/vscode/ffmpeg/build
cd /h/vscode/ffmpeg/FFmpeg || exit 1
make -j$(nproc) > $B/make2.log 2>&1 < /dev/null
rc=$?
echo "MAKE_EXIT=$rc"
[ $rc -ne 0 ] && tail -25 $B/make2.log
[ $rc -ne 0 ] && exit 1
make install > $B/make-install2.log 2>&1 < /dev/null
echo "INSTALL_EXIT=$?"
echo "### RESUME DONE"
