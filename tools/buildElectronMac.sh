#!/bin/bash
set -e

VERSION=$1

if [ -z "$VERSION" ]; then
  echo "Usage: $0 <electron-version>"
  exit 1
fi

declare -a macos_archs=("x64" "arm64")

for arch in "${macos_archs[@]}"; do
  echo "Building for Electron $VERSION on macOS $arch..."
  npx node-pre-gyp configure --target=$VERSION --arch=$arch --dist-url=https://electronjs.org/headers --module_name=node-printer --module_path=../lib/
  npx node-pre-gyp build package --runtime=electron --target=$VERSION --target_arch=$arch --build-from-source
done

echo "Done."