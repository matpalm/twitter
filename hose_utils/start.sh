#!/usr/bin/env bash
cd /data/twitter/gardenhose/
curl -s -u UID:PWD http://stream.twitter.com/1/statuses/sample.json > sample.`date +%Y%m%d`.json &
echo $! > curl.pid 
