#!/bin/bash
export PATH=/ucrt64/bin:/usr/bin:/bin
tr -d '\0' < /h/vscode/ffmpeg/build/make.log > /tmp/mk.txt
grep -a "multiple definition" /tmp/mk.txt | sed -E 's/.*lib([A-Za-z0-9._+-]+)\.a[^:]*:.text[^:]*: multiple definition of `([^'"'"']+)'"'"'; C:.*lib([A-Za-z0-9._+-]+)\.a.*/MULT \1::\2::\3/' | grep "^MULT" | sort -u
echo "===UNIQ==="
grep -ao "multiple definition of \`[^']*'" /tmp/mk.txt | sort -u
echo "OFF=$(ls /ucrt64/lib/*.dll.a.off 2>/dev/null | wc -l)"
