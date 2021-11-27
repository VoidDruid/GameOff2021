#!/usr/bin/env bash
set -e

tmp_file="/tmp/m4_temp_file"

m4_sources=`find logic -name "*.def.m4"`
echo "Using sources:" $m4_sources

m4_targets=(`find logic -name "*.gd.m4"`)

for m4_target in "${m4_targets[@]}"
do
    m4_destination=`sed -e 's/.m4//g' <<< "$m4_target"`
    echo "Processing" $m4_target "to " $m4_destination
    sed 's/#node(/node(/g' $m4_target > $tmp_file
    m4 $m4_sources $tmp_file > $m4_destination
done

exit 0
