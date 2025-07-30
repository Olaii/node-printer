#!/bin/bash
set -e

VERSION=$1

if [ -z "$VERSION" ]; then
  echo "Usage: $0 <electron-version>"
  exit 1
fi

# Build Electron macOS x64
echo "Building for Electron $VERSION on macOS x64..."
node-pre-gyp configure --target=$VERSION --arch=x64 --dist-url=https://electronjs.org/headers --module_name=electron-printer --module_path=../lib/
node-pre-gyp build package --runtime=electron --target=$VERSION --target_arch=x64 --build-from-source

# Build Electron macOS arm64 (for Apple Silicon)
echo "Building for Electron $VERSION on macOS arm64..."
node-pre-gyp configure --target=$VERSION --arch=arm64 --dist-url=https://electronjs.org/headers --module_name=electron-printer --module_path=../lib/
node-pre-gyp build package --runtime=electron --target=$VERSION --target_arch=arm64 --build-from-source

echo "Done."