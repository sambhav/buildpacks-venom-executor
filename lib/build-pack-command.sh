#!/bin/bash
set -ex

image_name=$1

tempdir=$(mktemp -d)

cd $tempdir

echo $2 > input.json

if [ -z "$image_name" ]; then
    echo "Invalid input. imageName must be provided."
    exit 1
fi

pack_command="pack build $image_name"

# Add the buildpacks
pack_command+=$(jq -r '[""] + .buildpacks | join(" -b ")' input.json)
# Add the env vars
pack_command+=$(jq -rj 'if has("env") then .env | to_entries | .[] | " -e \"" + .key + "=" + .value + "\"" else empty end' input.json)
# Add the project path
pack_command+=$(jq -r 'if .path then " -p \"" + .path + "\"" else empty end' input.json)
# Add the builder
pack_command+=$(jq -r 'if .builder then " --builder \"" + .builder + "\"" else empty end' input.json)
# Add the sbom output dir
pack_command+=$(jq -r 'if .sbomOutputDir then " --sbom-output-dir \"" + .sbomOutputDir + "\"" else empty end' input.json)
# Add the extra args
pack_command+=$(jq -r 'if .extraArgs then .extraArgs else empty end' input.json)
# Add verbose
pack_command+=$(jq -r 'if .verbose then " -v" else empty end' input.json)
# Add clear cache
pack_command+=$(jq -r 'if .clearCache then " --clear-cache" else empty end' input.json)
# Add no color
pack_command+=$(jq -r 'if .noColor then " --no-color" else empty end' input.json)
# Add trust builder
pack_command+=$(jq -r 'if .trustBuilder then " --trust-builder" else empty end' input.json)
# Add no pull builder
pack_command+=$(jq -r 'if .noPull then " --no-pull" else empty end' input.json)
# Add pull policy
pack_command+=$(jq -r 'if .pullPolicy then " --pull-policy \"" + .pullPolicy + "\"" else empty end' input.json)
# Add gid
pack_command+=$(jq -r 'if .gid then " --gid \"" + .gid + "\"" else empty end' input.json)
# Add network
pack_command+=$(jq -r 'if .network then " --network \"" + .network + "\"" else empty end' input.json)

echo $pack_command
