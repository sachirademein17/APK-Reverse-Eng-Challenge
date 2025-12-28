#!/bin/bash

# Simple Docker build script - minimal options
# Usage: ./docker-build-simple.sh

set -e

echo "🐳 Building APK with Docker..."
echo ""

# Build and run in one command
docker run --rm \
    -v "$(pwd):/project" \
    -v gradle-cache:/root/.gradle \
    -w /project \
    mingc/android-build-box:latest \
    bash -c "./gradlew assembleRelease --stacktrace --no-daemon"

echo ""
echo "✅ Build complete!"
echo "📦 APK: app/build/outputs/apk/release/app-release-unsigned.apk"
