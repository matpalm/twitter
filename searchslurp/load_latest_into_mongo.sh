#!/usr/bin/env bash
set -x
latest=world_cup_2.`date +'%Y%m%d_%H%M%S'`
mv world_cup_2.tweets $latest
touch world_cup_2.tweets
./load_into_mongo.rb < $latest
bzip2 -9 $latest
mv $latest.bz2 world_cup_results