#!/bin/bash

set -uo pipefail
IFS=$'\n\t'

# Config
# Repo name
REPO="github.com/lukasz-lobocki/gits"
# Executable name
OUTPUT_NAME="gits"
# Entry point package file
PACKAGE="main.go"
# List of architectures to build
goarchs=('amd64')
#goarchs=('amd64' 'arm64')

# Retrieveing git info
GIT_TAG="$( git describe --abbrev=0 --tags )"
GIT_HASH="$( git rev-parse --short HEAD )"
BUILD_DATE="$( date +%Y%m%d%H%M%S )"

# Checking if repo is dirty, to use it with build flags
if ! git diff --quiet; then
  DIRTY_DATE=".dirty.${BUILD_DATE}"
else
  DIRTY_DATE=""
fi

# For each architecture to be built
for i in "${goarchs[@]}"; do
  
  # Use to define target architecture of the build
  export GOARCH=${i}

  # Constructing build flags
  LDFLAGS="-X '${REPO}/cmd.semReleaseVersion=${GIT_TAG}+${GOARCH}.${GIT_HASH}${DIRTY_DATE}' -s -w"

  # Actual build
  go build \
    -ldflags "${LDFLAGS}" \
    -o "bin/${OUTPUT_NAME}-${GOARCH}" \
    "${PACKAGE}"

  # Display the result's characteristics
  file "bin/${OUTPUT_NAME}-${GOARCH}"
done

# For your local architecture, create default file without architecture name suffix
cp "bin/${OUTPUT_NAME}-$(dpkg --print-architecture)" "bin/${OUTPUT_NAME}"

# Local copy to directory of executables
sudo cp "bin/${OUTPUT_NAME}" /usr/local/bin/"${OUTPUT_NAME}"