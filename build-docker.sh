#!/bin/bash

# Docker build script for SecureApp APK
# This script builds the APK using Docker for consistent, reproducible builds

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

echo "=================================================="
echo "🐳 Docker APK Builder for SecureApp"
echo "=================================================="
echo ""

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo -e "${RED}❌ Docker is not installed!${NC}"
    echo ""
    echo "Please install Docker first:"
    echo "  Ubuntu/Debian: sudo apt-get install docker.io"
    echo "  Or visit: https://docs.docker.com/get-docker/"
    exit 1
fi

# Check if Docker daemon is running
if ! docker info &> /dev/null; then
    echo -e "${RED}❌ Docker daemon is not running!${NC}"
    echo ""
    echo "Please start Docker:"
    echo "  sudo systemctl start docker"
    echo "  sudo usermod -aG docker $USER  # Add your user to docker group"
    exit 1
fi

echo -e "${BLUE}✓ Docker is installed and running${NC}"
echo ""

# Clean previous builds (optional)
read -p "Clean previous build artifacts? [y/N] " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}🧹 Cleaning build directory...${NC}"
    rm -rf app/build app/.cxx
    echo -e "${GREEN}✓ Cleaned${NC}"
fi

echo ""
echo -e "${BLUE}📦 Building Docker image...${NC}"
echo "This may take a few minutes on first run (downloads Android SDK)"
echo ""

# Build using docker-compose
docker-compose build

echo ""
echo -e "${BLUE}🔨 Building APK...${NC}"
echo ""

# Run the build
docker-compose run --rm apk-builder

# Check if build succeeded
if [ -f "app/build/outputs/apk/release/app-release-unsigned.apk" ]; then
    echo ""
    echo "=================================================="
    echo -e "${GREEN}✅ BUILD SUCCESSFUL!${NC}"
    echo "=================================================="
    echo ""
    echo "📦 APK Location:"
    echo "   app/build/outputs/apk/release/app-release-unsigned.apk"
    echo ""
    
    # Show file info
    APK_SIZE=$(du -h app/build/outputs/apk/release/app-release-unsigned.apk | cut -f1)
    echo "📊 APK Size: $APK_SIZE"
    echo ""
    
    # Generate checksums
    echo -e "${BLUE}🔐 Generating checksums...${NC}"
    cd app/build/outputs/apk/release/
    sha256sum app-release-unsigned.apk > SHA256SUMS
    md5sum app-release-unsigned.apk > MD5SUMS
    cd "$SCRIPT_DIR"
    
    echo "   SHA256: $(cat app/build/outputs/apk/release/SHA256SUMS | cut -d' ' -f1)"
    echo ""
    
    # Sign the APK (optional)
    echo -e "${YELLOW}Would you like to sign the APK? [y/N]${NC}"
    read -p "" -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo ""
        echo -e "${BLUE}🔐 Signing APK...${NC}"
        
        # Create keystore if it doesn't exist
        if [ ! -f "app/secureapp.keystore" ]; then
            keytool -genkey -v \
                -keystore app/secureapp.keystore \
                -alias secureapp \
                -keyalg RSA \
                -keysize 2048 \
                -validity 10000 \
                -storepass securepass123 \
                -keypass securepass123 \
                -dname "CN=CTF, OU=APIIT, O=APIIT, L=Colombo, ST=Western, C=LK"
        fi
        
        # Sign
        jarsigner -verbose \
            -sigalg SHA256withRSA \
            -digestalg SHA-256 \
            -keystore app/secureapp.keystore \
            -storepass securepass123 \
            -keypass securepass123 \
            app/build/outputs/apk/release/app-release-unsigned.apk \
            secureapp
        
        # Zipalign
        if command -v zipalign &> /dev/null; then
            zipalign -f -v 4 \
                app/build/outputs/apk/release/app-release-unsigned.apk \
                app/build/outputs/apk/release/SecureApp.apk
            echo -e "${GREEN}✓ Signed and aligned: app/build/outputs/apk/release/SecureApp.apk${NC}"
        else
            mv app/build/outputs/apk/release/app-release-unsigned.apk \
               app/build/outputs/apk/release/SecureApp.apk
            echo -e "${GREEN}✓ Signed: app/build/outputs/apk/release/SecureApp.apk${NC}"
            echo -e "${YELLOW}⚠ zipalign not found (optional step skipped)${NC}"
        fi
    else
        # Just rename to SecureApp.apk
        cp app/build/outputs/apk/release/app-release-unsigned.apk \
           app/build/outputs/apk/release/SecureApp.apk
    fi
    
    echo ""
    echo "=================================================="
    echo -e "${GREEN}🎉 READY FOR CTF!${NC}"
    echo "=================================================="
    echo ""
    echo "📱 Final APK: app/build/outputs/apk/release/SecureApp.apk"
    echo ""
    echo "Next steps:"
    echo "  1. Test on Android device/emulator:"
    echo "     adb install app/build/outputs/apk/release/SecureApp.apk"
    echo ""
    echo "  2. Verify flag works:"
    echo "     Flag: APIIT{N4t1v3_4nd_J4v4_Obfusc4t1on_M4st3r}"
    echo ""
    echo "  3. Distribute to CTF competitors (APK only, not source!)"
    echo ""
    
else
    echo ""
    echo "=================================================="
    echo -e "${RED}❌ BUILD FAILED${NC}"
    echo "=================================================="
    echo ""
    echo "Check the logs above for errors."
    echo ""
    exit 1
fi
