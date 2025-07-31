#!/bin/bash
set -e

VERSION=$1

if [ -z "$VERSION" ]; then
  echo "Usage: $0 <electron-version>"
  exit 1
fi

declare -a linux_archs=("x64" "ia32" "arm" "arm64")

for arch in "${linux_archs[@]}"; do
  echo "Building for Electron $VERSION on Linux $arch..."
  npx node-pre-gyp configure --target=$VERSION --arch=$arch --dist-url=https://electronjs.org/headers --module_name=node-printer --module_path=../lib/
  npx node-pre-gyp build package --runtime=electron --target=$VERSION --target_arch=$arch --build-from-source
done

echo "Done."
