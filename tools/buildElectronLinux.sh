#!/bin/bash
set -e

VERSION=$1

if [ -z "$VERSION" ]; then
  echo "Usage: $0 <electron-version>"
  exit 1
fi

# Build Electron Linux 64bit (x64)
echo "Building for Electron $VERSION on Linux x64..."
node-pre-gyp configure --target=$VERSION --arch=x64 --dist-url=https://electronjs.org/headers --module_name=electron-printer --module_path=../lib/
node-pre-gyp build package --runtime=electron --target=$VERSION --target_arch=x64 --build-from-source

# Build Electron Linux 32bit (ia32)
echo "Building for Electron $VERSION on Linux ia32..."
node-pre-gyp configure --target=$VERSION --arch=ia32 --dist-url=https://electronjs.org/headers --module_name=electron-printer --module_path=../lib/
node-pre-gyp build package --runtime=electron --target=$VERSION --target_arch=ia32 --build-from-source

# Build Electron Linux ARM 32bit (armv7l) for Raspberry Pi 2/3/4 (32-bit OS)
echo "Building for Electron $VERSION on Linux arm..."
node-pre-gyp configure --target=$VERSION --arch=arm --dist-url=https://electronjs.org/headers --module_name=electron-printer --module_path=../lib/
node-pre-gyp build package --runtime=electron --target=$VERSION --target_arch=arm --build-from-source

# Build Electron Linux ARM 64bit (arm64) for Raspberry Pi 3/4/5 (64-bit OS)
echo "Building for Electron $VERSION on Linux arm64..."
node-pre-gyp configure --target=$VERSION --arch=arm64 --dist-url=https://electronjs.org/headers --module_name=electron-printer --module_path=../lib/
node-pre-gyp build package --runtime=electron --target=$VERSION --target_arch=arm64 --build-from-source

echo "Done."
