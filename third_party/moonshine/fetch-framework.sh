#!/usr/bin/env bash
# Downloads the prebuilt Moonshine xcframework into this directory.
#
# The framework is ~214 MB unpacked, so it is not committed. Run this once
# after cloning, before `pod install`.
set -euo pipefail

VERSION="v0.1.5"
URL="https://github.com/moonshine-ai/moonshine-swift/releases/download/${VERSION}/Moonshine.xcframework.zip"

cd "$(dirname "$0")"

if [ -d "Moonshine.xcframework" ]; then
  echo "Moonshine.xcframework already present; nothing to do."
  exit 0
fi

echo "Downloading Moonshine ${VERSION}..."
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

curl -sSL -o "$tmp/moonshine.zip" "$URL"
unzip -q "$tmp/moonshine.zip" -d "$tmp"
mv "$tmp/Moonshine.xcframework" .

echo "Done: $(du -sh Moonshine.xcframework | cut -f1) in $(pwd)"
