#!/bin/bash
set -e # Exit immediately if a command exits with a non-zero status.

if [ -z "$1" ]; then
  echo "Usage: $0 <release-version>"
  echo "e.g.: $0 2.0.5"
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
  "15.3.5"
  "19.1.9"
  "22.3.27"
  "25.9.8"
  "27.3.11"
  "28.3.3"
  "29.4.0"
  "30.1.0"
  "31.2.1"
)

# Remove old build directory
rm -rf "$SOURCE_PATH/build"

# Create release path
mkdir -p "$SOURCE_PATH/releases/$RELEASE_VERSION"

for version in "${node_versions[@]}"; do
  echo "Building for Node.js version: $version..."
  npx node-pre-gyp configure --target=$version --module_name=node-printer
  npx node-pre-gyp build package --target=$version --target_arch=x64 --build-from-source
  npx node-pre-gyp build package --target=$version --target_arch=arm64 --build-from-source
  rsync -av "$SOURCE_PATH/build/stage/$PACKAGE_VERSION/" "$SOURCE_PATH/releases/$RELEASE_VERSION/" --remove-source-files
  echo "Done"
done

for version in "${electron_versions[@]}"; do
  echo "Building for Electron version: $version..."
  npx node-pre-gyp configure --target=$version --dist-url=https://electronjs.org/headers --module_name=node-printer
  npx node-pre-gyp build package --target=$version --target_arch=x64 --runtime=electron --build-from-source
  npx node-pre-gyp build package --target=$version --target_arch=arm64 --runtime=electron --build-from-source
  rsync -av "$SOURCE_PATH/build/stage/$PACKAGE_VERSION/" "$SOURCE_PATH/releases/$RELEASE_VERSION/" --remove-source-files
  echo "Done"
done

echo "Finished successfully!"