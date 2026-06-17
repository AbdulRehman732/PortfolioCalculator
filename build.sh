#!/usr/bin/env bash
set -euo pipefail

echo "Installing Flutter SDK (stable channel)..."
if [ ! -d "flutter" ]; then
  git clone --depth 1 -b stable https://github.com/flutter/flutter.git flutter
fi

export PATH="$PWD/flutter/bin:$PATH"

echo "Flutter version:"
flutter --version

echo "Pre-caching web artifacts..."
flutter precache --web

cd psx_app

echo "Fetching packages..."
flutter pub get

echo "Building Flutter web release..."
flutter build web --release

echo "Build finished. Output at psx_app/build/web"
