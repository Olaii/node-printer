<#
.SYNOPSIS
  Builds the native addon for a specific Electron version on Windows for x64 and ia32 architectures.
.PARAMETER Version
  The target Electron version (e.g., "6.0.7").
#>
param (
  [Parameter(Mandatory=$true, HelpMessage="The Electron version to build against.")]
  [string]$Version
)

# Stop script on first error
$ErrorActionPreference = "Stop"

Write-Host "Building Electron Version -> $Version for x64, ia32, and arm64"

# Build Electron Windows 64bit
Write-Host "Building for x64..."
npx node-pre-gyp configure --target=$Version --arch=x64 --dist-url=https://electronjs.org/headers --module_name=electron-printer --module_path=../lib/
npx node-pre-gyp build package --runtime=electron --target=$Version --target_arch=x64 --build-from-source

# Build Electron Windows 32bit
Write-Host "Building for ia32..."
npx node-pre-gyp configure --target=$Version --arch=ia32 --dist-url=https://electronjs.org/headers --module_name=electron-printer --module_path=../lib/
npx node-pre-gyp build package --runtime=electron --target=$Version --target_arch=ia32 --build-from-source

Write-Host "Building for arm64..."
npx node-pre-gyp configure --target=$Version --arch=arm64 --dist-url=https://electronjs.org/headers --module_name=electron-printer --module_path=../lib/
npx node-pre-gyp build package --runtime=electron --target=$Version --target_arch=arm64 --build-from-source

Write-Host "Done."