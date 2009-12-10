#!/usr/bin/env bash
set -x
mkdir /data2/tmp
cd /data2/tmp
scp newt:/data/twitter/gardenhose/*$1* .
find -type f -name \*$1\* -exec zcat {} >> /data2/sample \;
cat /data2/sample | perl -ne'print $_ if /}\s+$/;' | gzip -9 > /data/twitter/gardenhose/sample.$1.json.gz
rm /data2/sample
rm *$1*
cd ~/dev/twitter/hose_utils
num_lines.sh /data/twitter/gardenhose/sample.$1.json.gz >> sizes
