#!/usr/bin/env bash
set -e

jsonnet_targets=(`find gamedata -not -name "*.lib.jsonnet" -name "*.jsonnet"`)

echo "Clearing gamedata/objects dir..."
rm -rf gamedata/objects/*

for jsonnet_target in "${jsonnet_targets[@]}"
do
    jsonnet_destination=gamedata/objects/`basename -- $(sed -e 's/.jsonnet/.json/g' <<< "$jsonnet_target")`
    echo "Processing" $jsonnet_target "to " $jsonnet_destination
    jsonnet --jpath gamedata $jsonnet_target -o $jsonnet_destination
done

exit 0
