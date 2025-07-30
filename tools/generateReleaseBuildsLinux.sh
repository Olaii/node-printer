#!/bin/bash
set -e # Exit immediately if a command exits with a non-zero status.

if [ -z "$1" ]; then
  echo "Usage: $0 <release-version>"
  echo "e.g.: $0 3.0.0"
  exit 1
fi

RELEASE_VERSION=$1
PACKAGE_VERSION=$(node -pe "require('./package.json').version")
SOURCE_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"

# Modern, relevant Node.js and Electron versions
# N-API provides forward compatibility, so we target major LTS versions.
declare -a node_versions=(
  "16.20.2"
  "18.20.2"
  "20.14.0"
  "22.4.0"
)

declare -a electron_versions=(
  "28.3.3"
  "29.4.0"
  "30.1.0"
  "31.2.1"
)

declare -a linux_archs=("x64" "ia32" "arm" "arm64")

# remove old build directory
rm -rf "$SOURCE_PATH/build"

# create release path
mkdir -p "$SOURCE_PATH/releases/$RELEASE_VERSION"

for version in "${node_versions[@]}"; do
  echo "Building for Node.js version: $version"
  for arch in "${linux_archs[@]}"; do
    echo "  Building for arch: $arch..."
    npx node-pre-gyp configure --target=$version --arch=$arch --module_name=electron-printer
    npx node-pre-gyp build package --target=$version --target_arch=$arch --build-from-source
  done
  rsync -av "$SOURCE_PATH/build/stage/$PACKAGE_VERSION/" "$SOURCE_PATH/releases/$RELEASE_VERSION/" --remove-source-files
  echo "Done building for Node.js $version"
done

for version in "${electron_versions[@]}"; do
  echo "Building for Electron version: $version"
  for arch in "${linux_archs[@]}"; do
    echo "  Building for arch: $arch..."
    npx node-pre-gyp configure --target=$version --arch=$arch --dist-url=https://electronjs.org/headers --module_name=electron-printer
    npx node-pre-gyp build package --target=$version --target_arch=$arch --runtime=electron --build-from-source
  done
  rsync -av "$SOURCE_PATH/build/stage/$PACKAGE_VERSION/" "$SOURCE_PATH/releases/$RELEASE_VERSION/" --remove-source-files
  echo "Done building for Electron $version"
done

echo "Finished successfully!"
