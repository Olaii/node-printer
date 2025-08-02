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

Write-Host "Building Electron Version -> $Version"

$windows_archs = @("x64", "ia32", "arm64")

foreach ($arch in $windows_archs) {
  Write-Host "Building for Windows $arch..."
  npx node-pre-gyp configure --target=$Version --arch=$arch --dist-url=https://electronjs.org/headers --module_name=node-printer --module_path=../lib/
  npx node-pre-gyp build package --runtime=electron --target=$Version --target_arch=$arch --build-from-source
}

Write-Host "Done."