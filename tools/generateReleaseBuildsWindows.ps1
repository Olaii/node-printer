<#
.SYNOPSIS
  Builds pre-compiled binaries for a release.
.PARAMETER Release
  The release version tag (e.g., "2.0.5").
#>
param (
  [Parameter(Mandatory=$true)][string]$Release
)

# Stop script on first error
$ErrorActionPreference = "Stop"

$SOURCE_PATH = Split-Path -Parent $MyInvocation.MyCommand.Definition
$RELEASE_VERSION = $Release
$PACKAGE_VERSION = node -pe "require('./package.json').version"

# Modern, relevant Node.js and Electron versions
# N-API provides forward compatibility, so we target major LTS versions.
$node_versions = @(
  "16.20.2",
  "18.20.2",
  "20.14.0",
  "22.4.0"
)

$electron_versions = @(
  "28.3.3",
  "29.4.0",
  "30.1.0",
  "31.2.1"
)

# remove old build directory
Remove-Item -Recurse -Force "$SOURCE_PATH\..\build" -ErrorAction Ignore

# create release path
New-Item "$SOURCE_PATH\..\releases\$RELEASE_VERSION" -ItemType Directory -ErrorAction SilentlyContinue | Out-Null

foreach ($version in $node_versions) {
  Write-Output "Building for node version: $version..."
  npx node-pre-gyp configure --target=$version --module_name=electron-printer
  npx node-pre-gyp build package --target=$version --target_arch=x64 --build-from-source
  npx node-pre-gyp build package --target=$version --target_arch=ia32 --build-from-source
  Copy-Item -Force -Recurse "$SOURCE_PATH\..\build\stage\$PACKAGE_VERSION\*" -Destination "$SOURCE_PATH\..\releases\$RELEASE_VERSION"
  Remove-Item -Recurse -Force "$SOURCE_PATH\..\build\stage"
  Write-Output "Done"
}

foreach ($version in $electron_versions) {
  Write-Output "Building for electron version: $version..."
  npx node-pre-gyp configure --target=$version --dist-url=https://electronjs.org/headers --module_name=electron-printer
  npx node-pre-gyp build package --target=$version --target_arch=x64 --runtime=electron --build-from-source
  npx node-pre-gyp build package --target=$version --target_arch=ia32 --runtime=electron --build-from-source
  Copy-Item -Force -Recurse "$SOURCE_PATH\..\build\stage\$PACKAGE_VERSION\*" -Destination "$SOURCE_PATH\..\releases\$RELEASE_VERSION"
  Remove-Item -Recurse -Force "$SOURCE_PATH\..\build\stage"
  Write-Output "Done"
}

Write-Output "Finished successfully!"