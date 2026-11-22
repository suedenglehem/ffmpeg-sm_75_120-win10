#!/bin/bash
export PATH=/ucrt64/bin:/usr/bin:/bin
cd /ucrt64/lib || exit 1

# 1) force FFmpeg to re-run pkg-config probes (drop cached libs incl. stale -lgcc_s)
rm -f /h/vscode/ffmpeg/FFmpeg/ffbuild/pkgconfig.cfg

# 2) find sha1 symbols defined by BOTH libssh.a and libzmq.a
nm -g --defined-only libssh.a  2>/dev/null | awk '/ T /{print $3}' | grep -i "^sha1" | sort -u > /tmp/ssh.sha1
nm -g --defined-only libzmq.a  2>/dev/null | awk '/ T /{print $3}' | grep -i "^sha1" | sort -u > /tmp/zmq.sha1
echo "ssh defines:"; cat /tmp/ssh.sha1
echo "zmq defines:"; cat /tmp/zmq.sha1
comm -12 /tmp/ssh.sha1 /tmp/zmq.sha1 > /tmp/common.sha1
echo "common (will rename in libssh.a):"; cat /tmp/common.sha1

# 3) rename in libssh.a (keep backup)
if [ -s /tmp/common.sha1 ] && [ ! -f libssh.a.orig ]; then
  cp libssh.a libssh.a.orig
  : > /tmp/redef.txt
  while read -r s; do echo "$s ssh_$s" >> /tmp/redef.txt; done < /tmp/common.sha1
  objcopy --redefine-syms=/tmp/redef.txt libssh.a.orig libssh.a && echo OBJCOPY_OK
  nm -g --defined-only libssh.a | grep -c "T ssh_sha1\|T sha1" | head -1
fi
