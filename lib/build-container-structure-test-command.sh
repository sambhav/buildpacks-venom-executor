#!/bin/bash
set -ex

image_name=$1

tempdir=$(mktemp -d)

cd $tempdir

echo $2 > config.json
echo $3 > input.json

if [ -z "$image_name" ]; then
    echo "Invalid input. imageName must be provided."
    exit 1
fi

test_command="container-structure-test test --output json --image $image_name --config config.json"
# Add verbose
test_command+=$(jq -r 'if .verbose then " --verbosity debug" else empty end' input.json)
# Add pull
test_command+=$(jq -r 'if .pull then " --pull" else empty end' input.json)
# Add no color
test_command+=$(jq -r 'if .noColor then " --no-color" else empty end' input.json)
echo $test_command
