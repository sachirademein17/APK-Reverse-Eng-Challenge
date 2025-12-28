#!/bin/bash

# ============================================
# SecureApp - Automated Build Script
# ============================================

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
KEYSTORE_FILE="secureapp.keystore"
KEYSTORE_ALIAS="secureapp"
KEYSTORE_PASS="securepass123"
KEY_PASS="securepass123"
KEY_DNAME="CN=CTF, OU=APIIT, O=APIIT, L=Colombo, S=Western, C=LK"

OUTPUT_DIR="release"
OUTPUT_APK="SecureApp.apk"

echo -e "${BLUE}================================${NC}"
echo -e "${BLUE}🔨 SecureApp Build Script${NC}"
echo -e "${BLUE}================================${NC}\n"

# ============================================
# 1. Check Prerequisites
# ============================================
echo -e "${YELLOW}[1/7] Checking prerequisites...${NC}"

# Check if gradle wrapper exists
if [ ! -f "gradlew" ]; then
    echo -e "${RED}❌ Error: gradlew not found. Are you in the correct directory?${NC}"
    exit 1
fi

# Check if Java is installed
if ! command -v java &> /dev/null; then
    echo -e "${RED}❌ Error: Java is not installed${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Java version:${NC}"
java -version 2>&1 | head -n 1

# Check if Android SDK is set
if [ -z "$ANDROID_HOME" ]; then
    echo -e "${YELLOW}⚠ Warning: ANDROID_HOME not set${NC}"
    echo -e "${YELLOW}  Gradle will attempt to download required components${NC}"
fi

echo -e "${GREEN}✓ Prerequisites checked${NC}\n"

# ============================================
# 2. Clean Previous Builds
# ============================================
echo -e "${YELLOW}[2/7] Cleaning previous builds...${NC}"

./gradlew clean > /dev/null 2>&1

echo -e "${GREEN}✓ Cleaned${NC}\n"

# ============================================
# 3. Build Release APK
# ============================================
echo -e "${YELLOW}[3/7] Building release APK...${NC}"
echo -e "  ${BLUE}This may take a few minutes...${NC}"

./gradlew assembleRelease

if [ ! -f "app/build/outputs/apk/release/app-release-unsigned.apk" ]; then
    echo -e "${RED}❌ Build failed!${NC}"
    exit 1
fi

echo -e "${GREEN}✓ APK built successfully${NC}\n"

# ============================================
# 4. Create/Verify Keystore
# ============================================
echo -e "${YELLOW}[4/7] Setting up keystore...${NC}"

if [ ! -f "$KEYSTORE_FILE" ]; then
    echo -e "  ${BLUE}Creating new keystore...${NC}"
    
    keytool -genkey -v \
        -keystore "$KEYSTORE_FILE" \
        -alias "$KEYSTORE_ALIAS" \
        -keyalg RSA \
        -keysize 2048 \
        -validity 10000 \
        -storepass "$KEYSTORE_PASS" \
        -keypass "$KEY_PASS" \
        -dname "$KEY_DNAME" \
        > /dev/null 2>&1
    
    echo -e "${GREEN}✓ Keystore created${NC}"
else
    echo -e "${GREEN}✓ Using existing keystore${NC}"
fi

echo ""

# ============================================
# 5. Sign APK
# ============================================
echo -e "${YELLOW}[5/7] Signing APK...${NC}"

# Copy unsigned APK
cp app/build/outputs/apk/release/app-release-unsigned.apk \
   app/build/outputs/apk/release/app-release-signed.apk

# Sign with jarsigner
jarsigner -verbose \
    -sigalg SHA256withRSA \
    -digestalg SHA-256 \
    -keystore "$KEYSTORE_FILE" \
    -storepass "$KEYSTORE_PASS" \
    -keypass "$KEY_PASS" \
    app/build/outputs/apk/release/app-release-signed.apk \
    "$KEYSTORE_ALIAS" \
    > /dev/null 2>&1

echo -e "${GREEN}✓ APK signed${NC}\n"

# ============================================
# 6. Zipalign APK
# ============================================
echo -e "${YELLOW}[6/7] Optimizing APK (zipalign)...${NC}"

# Find zipalign
ZIPALIGN=""
if [ -n "$ANDROID_HOME" ]; then
    ZIPALIGN=$(find "$ANDROID_HOME/build-tools" -name "zipalign" 2>/dev/null | head -n 1)
fi

if [ -z "$ZIPALIGN" ]; then
    echo -e "${YELLOW}⚠ Warning: zipalign not found, skipping optimization${NC}"
    cp app/build/outputs/apk/release/app-release-signed.apk \
       app/build/outputs/apk/release/"$OUTPUT_APK"
else
    $ZIPALIGN -v 4 \
        app/build/outputs/apk/release/app-release-signed.apk \
        app/build/outputs/apk/release/"$OUTPUT_APK" \
        > /dev/null 2>&1
    
    echo -e "${GREEN}✓ APK optimized${NC}"
fi

echo ""

# ============================================
# 7. Create Release Package
# ============================================
echo -e "${YELLOW}[7/7] Creating release package...${NC}"

# Create release directory
mkdir -p "$OUTPUT_DIR"

# Copy APK
cp app/build/outputs/apk/release/"$OUTPUT_APK" "$OUTPUT_DIR/"

# Generate checksums
cd "$OUTPUT_DIR"
sha256sum "$OUTPUT_APK" > SHA256SUMS
md5sum "$OUTPUT_APK" > MD5SUMS

# Create README for competitors
cat > README.txt << 'EOF'
╔════════════════════════════════════════════════════════════╗
║        SecureApp - APK Reverse Engineering Challenge       ║
╚════════════════════════════════════════════════════════════╝

Category: Mobile / Reverse Engineering
Difficulty: INSANE (⭐⭐⭐⭐⭐)
Points: 1000
Flag Format: APIIT{...}

OBJECTIVE:
----------
Reverse engineer this Android application to extract the hidden flag.
This challenge includes multiple layers of security mechanisms that
will test your mobile reverse engineering skills.

INSTALLATION:
-------------
adb install SecureApp.apk

INSTRUCTIONS:
-------------
1. Install the APK on your Android device or emulator
2. Launch the application
3. Analyze the APK using reverse engineering tools
4. Bypass security mechanisms
5. Extract the flag
6. Submit the flag in format: APIIT{...}

TOOLS YOU MIGHT NEED:
---------------------
- jadx / jadx-gui (Java decompiler)
- Ghidra / IDA Pro (Native code analysis)
- Frida (Dynamic instrumentation)
- apktool (APK manipulation)
- Android Studio (Debugging)
- objection (Frida-based testing tool)

SECURITY LAYERS:
----------------
⚠ This app includes multiple security mechanisms:
  • ProGuard obfuscation
  • Native code (JNI/NDK)
  • Anti-debugging checks
  • Root detection
  • Certificate pinning
  • Integrity checks
  • String obfuscation
  • Reflection-based verification

HINTS:
------
• The flag is split between Java and native code
• You'll need to analyze both layers
• Dynamic analysis is your friend
• Don't skip the native library
• Look for hidden classes loaded via reflection

GOOD LUCK!
----------
This is an INSANE difficulty challenge. Only the most skilled
reverse engineers will succeed. Don't give up!

═══════════════════════════════════════════════════════════════

For technical support during the CTF, contact the organizers.
EOF

# Create technical info file
cat > TECHNICAL_INFO.txt << EOF
SecureApp - Technical Information
==================================

APK Details:
-----------
Package Name: com.ctf.secureapp
Version: 1.0
Min SDK: 24 (Android 7.0)
Target SDK: 33 (Android 13)
Architectures: arm64-v8a, armeabi-v7a, x86, x86_64

Build Information:
------------------
Built: $(date)
Build Tool: Gradle 8.0+
ProGuard: Enabled
Native Code: Yes (C++)

File Checksums:
--------------
SHA-256: $(cat SHA256SUMS)
MD5: $(cat MD5SUMS)

File Size: $(du -h "$OUTPUT_APK" | cut -f1)

Installation:
-------------
Requires Android 7.0 (API 24) or higher
Works on both physical devices and emulators
No special permissions required

Verification:
-------------
To verify APK integrity:
  sha256sum -c SHA256SUMS
  md5sum -c MD5SUMS

To verify APK signature:
  apksigner verify --verbose SecureApp.apk

═══════════════════════════════════════════════════════════
EOF

cd ..

echo -e "${GREEN}✓ Release package created${NC}\n"

# ============================================
# 8. Display Summary
# ============================================
echo -e "${BLUE}================================${NC}"
echo -e "${GREEN}✅ Build Successful!${NC}"
echo -e "${BLUE}================================${NC}\n"

echo -e "${BLUE}📦 Release Package:${NC}"
echo -e "  Location: ${GREEN}$OUTPUT_DIR/${NC}"
echo -e "  APK: ${GREEN}$OUTPUT_APK${NC}"

# Get file info
APK_SIZE=$(du -h "$OUTPUT_DIR/$OUTPUT_APK" | cut -f1)
APK_SHA256=$(cat "$OUTPUT_DIR/SHA256SUMS" | cut -d' ' -f1)

echo -e "\n${BLUE}📊 APK Information:${NC}"
echo -e "  Size: ${GREEN}$APK_SIZE${NC}"
echo -e "  SHA-256: ${GREEN}${APK_SHA256:0:32}...${NC}"

# Get APK details if aapt is available
if command -v aapt &> /dev/null; then
    echo -e "\n${BLUE}📱 Package Details:${NC}"
    aapt dump badging "$OUTPUT_DIR/$OUTPUT_APK" 2>/dev/null | grep -E "package:|sdkVersion:|targetSdkVersion:|native-code:" | while read line; do
        echo -e "  ${GREEN}$line${NC}"
    done
fi

echo -e "\n${BLUE}📁 Release Files:${NC}"
ls -lh "$OUTPUT_DIR/" | tail -n +2 | awk '{print "  " $9 " (" $5 ")"}'

echo -e "\n${BLUE}🔐 Security:${NC}"
echo -e "  Signed: ${GREEN}✓${NC}"
echo -e "  Obfuscated: ${GREEN}✓${NC}"
echo -e "  Optimized: ${GREEN}✓${NC}"

echo -e "\n${BLUE}🚀 Next Steps:${NC}"
echo -e "  1. Test APK: ${YELLOW}adb install $OUTPUT_DIR/$OUTPUT_APK${NC}"
echo -e "  2. Verify flag works correctly"
echo -e "  3. Test on multiple devices/emulators"
echo -e "  4. Distribute ${YELLOW}$OUTPUT_DIR/$OUTPUT_APK${NC} to competitors"

echo -e "\n${BLUE}⚠ Important:${NC}"
echo -e "  • Keep source code confidential"
echo -e "  • Backup keystore: ${YELLOW}$KEYSTORE_FILE${NC}"
echo -e "  • Only distribute files in ${YELLOW}$OUTPUT_DIR/${NC}"

echo -e "\n${GREEN}✨ Build completed successfully!${NC}\n"

# ============================================
# Optional: Quick Test
# ============================================
read -p "Do you want to install and test the APK now? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo -e "\n${YELLOW}Installing APK...${NC}"
    
    # Check if device is connected
    if ! adb devices | grep -q "device$"; then
        echo -e "${RED}❌ No Android device/emulator connected${NC}"
        echo -e "${YELLOW}Connect a device and run: adb install $OUTPUT_DIR/$OUTPUT_APK${NC}"
    else
        adb install -r "$OUTPUT_DIR/$OUTPUT_APK"
        
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}✓ APK installed successfully${NC}"
            echo -e "\n${YELLOW}Launching app...${NC}"
            adb shell am start -n com.ctf.secureapp/.MainActivity
            echo -e "${GREEN}✓ App launched${NC}"
            echo -e "\n${BLUE}You can now test the app on your device${NC}"
        else
            echo -e "${RED}❌ Installation failed${NC}"
        fi
    fi
fi

echo -e "\n${BLUE}================================${NC}"
echo -e "${GREEN}Build script completed!${NC}"
echo -e "${BLUE}================================${NC}\n"
