#!/usr/bin/env bash
set -x
mkdir /data2/tmp.$$
cd /data2/tmp.$$
scp newt:/data/twitter/gardenhose/*$1* .
find -type f -name \*$1\* -exec zcat {} >> all_sample \;
cat all_sample | perl -ne'print $_ if /}\s+$/;' | gzip -9 > /data/twitter/gardenhose/sample.$1.json.gz
cd ~/dev/twitter/hose_utils
num_lines.sh /data/twitter/gardenhose/sample.$1.json.gz >> sizes
rm -rf /data2/tmp.$$
tail /home/mat/dev/twitter/hose_utils/sizes
