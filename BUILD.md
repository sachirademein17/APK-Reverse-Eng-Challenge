# 🔨 Build Instructions - SecureApp Challenge

## Prerequisites

### Required Software:

1. **Android Studio** (latest stable version)
   - Download: https://developer.android.com/studio
   - Includes: Android SDK, SDK Platform Tools, SDK Build Tools

2. **Android NDK**
   - Download through Android Studio SDK Manager
   - Or standalone: https://developer.android.com/ndk/downloads
   - Required version: NDK 21.0+

3. **JDK (Java Development Kit)**
   - Version: JDK 11 or JDK 17
   - Download: https://adoptium.net/

4. **Command Line Tools:**
   ```bash
   # On Linux/macOS
   sudo apt-get install git gradle
   
   # On macOS with Homebrew
   brew install gradle
   ```

### Environment Setup:

```bash
# Set ANDROID_HOME
export ANDROID_HOME=$HOME/Android/Sdk
export PATH=$PATH:$ANDROID_HOME/platform-tools
export PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin

# Set NDK path
export ANDROID_NDK_HOME=$ANDROID_HOME/ndk/21.4.7075529

# Verify installations
java -version          # Should show JDK 11 or 17
gradle --version       # Should show Gradle 7.0+
adb version           # Should show Android Debug Bridge version
```

---

## 🏗️ Building the APK

### Method 1: Using Android Studio (Recommended)

1. **Open Project:**
   ```bash
   # Launch Android Studio
   studio.sh
   # or on macOS/Windows, launch from Applications
   
   # Open project: File → Open → Select APK_Challenge folder
   ```

2. **Sync Gradle:**
   - Android Studio will prompt to sync
   - Click "Sync Now" in the notification bar
   - Wait for dependencies to download

3. **Build Release APK:**
   - Menu: Build → Generate Signed Bundle / APK
   - Select: APK
   - Click "Next"
   - Create new keystore or use existing
   - Fill keystore details:
     ```
     Keystore path: /path/to/keystore.jks
     Keystore password: [your password]
     Key alias: secureapp
     Key password: [your password]
     ```
   - Click "Next"
   - Select "release" build variant
   - Check "V2 (Full APK Signature)"
   - Click "Finish"

4. **Locate APK:**
   ```
   APK_Challenge/app/build/outputs/apk/release/app-release.apk
   ```

### Method 2: Using Gradle Command Line

1. **Build Debug APK (for testing):**
   ```bash
   cd APK_Challenge
   ./gradlew assembleDebug
   
   # Output: app/build/outputs/apk/debug/app-debug.apk
   ```

2. **Build Release APK (unsigned):**
   ```bash
   ./gradlew assembleRelease
   
   # Output: app/build/outputs/apk/release/app-release-unsigned.apk
   ```

3. **Sign APK Manually:**
   ```bash
   # Generate keystore (first time only)
   keytool -genkey -v \
     -keystore secureapp.keystore \
     -alias secureapp \
     -keyalg RSA \
     -keysize 2048 \
     -validity 10000 \
     -storepass securepass123 \
     -keypass securepass123 \
     -dname "CN=CTF, OU=APIIT, O=APIIT, L=Colombo, S=Western, C=LK"
   
   # Sign the APK
   jarsigner -verbose \
     -sigalg SHA256withRSA \
     -digestalg SHA-256 \
     -keystore secureapp.keystore \
     -storepass securepass123 \
     -keypass securepass123 \
     app/build/outputs/apk/release/app-release-unsigned.apk \
     secureapp
   
   # Zipalign (optimize)
   zipalign -v 4 \
     app/build/outputs/apk/release/app-release-unsigned.apk \
     app/build/outputs/apk/release/SecureApp.apk
   
   # Verify signature
   apksigner verify app/build/outputs/apk/release/SecureApp.apk
   ```

### Method 3: Automated Build Script

Create `build.sh`:

```bash
#!/bin/bash

echo "🔨 Building SecureApp APK..."

# Clean previous builds
./gradlew clean

# Build release APK
./gradlew assembleRelease

# Check if build succeeded
if [ -f "app/build/outputs/apk/release/app-release-unsigned.apk" ]; then
    echo "✅ Build successful!"
    
    # Sign APK
    echo "🔑 Signing APK..."
    
    KEYSTORE="secureapp.keystore"
    STOREPASS="securepass123"
    KEYPASS="securepass123"
    ALIAS="secureapp"
    
    # Create keystore if doesn't exist
    if [ ! -f "$KEYSTORE" ]; then
        keytool -genkey -v \
          -keystore $KEYSTORE \
          -alias $ALIAS \
          -keyalg RSA \
          -keysize 2048 \
          -validity 10000 \
          -storepass $STOREPASS \
          -keypass $KEYPASS \
          -dname "CN=CTF, OU=APIIT, O=APIIT, L=Colombo, S=Western, C=LK"
    fi
    
    # Sign
    jarsigner -verbose \
      -sigalg SHA256withRSA \
      -digestalg SHA-256 \
      -keystore $KEYSTORE \
      -storepass $STOREPASS \
      -keypass $KEYPASS \
      app/build/outputs/apk/release/app-release-unsigned.apk \
      $ALIAS
    
    # Zipalign
    zipalign -v 4 \
      app/build/outputs/apk/release/app-release-unsigned.apk \
      app/build/outputs/apk/release/SecureApp.apk
    
    echo "✅ APK signed and aligned!"
    echo "📦 Output: app/build/outputs/apk/release/SecureApp.apk"
    
    # Get APK size
    SIZE=$(du -h app/build/outputs/apk/release/SecureApp.apk | cut -f1)
    echo "📊 APK Size: $SIZE"
    
else
    echo "❌ Build failed!"
    exit 1
fi
```

Make executable and run:
```bash
chmod +x build.sh
./build.sh
```

---

## 🧪 Testing the APK

### 1. Install on Emulator/Device

```bash
# List connected devices
adb devices

# Install APK
adb install app/build/outputs/apk/release/SecureApp.apk

# If already installed, reinstall
adb install -r app/build/outputs/apk/release/SecureApp.apk
```

### 2. Launch the App

```bash
# Start app
adb shell am start -n com.ctf.secureapp/.MainActivity

# Or click app icon on device
```

### 3. Test Correct Flag

```bash
# Input correct flag
adb shell input text "APIIT{N4t1v3_4nd_J4v4_Obfusc4t1on_M4st3r}"

# Click verify button (coordinate-based)
adb shell input tap 540 1000  # Adjust coordinates for your device

# Or use monkey tool
adb shell monkey -p com.ctf.secureapp -c android.intent.category.LAUNCHER 1
```

### 4. Test Incorrect Flag

```bash
# Input wrong flag
adb shell input text "APIIT{wrong_flag}"

# Should show "Incorrect flag!"
```

### 5. View Logs

```bash
# View app logs
adb logcat | grep SecureApp

# View all logs
adb logcat

# Clear logs first
adb logcat -c
```

### 6. Test Anti-Debugging

```bash
# Try to debug
adb shell am set-debug-app -w com.ctf.secureapp
adb shell am start -D -n com.ctf.secureapp/.MainActivity

# Should detect debugger and fail
```

---

## 🐛 Troubleshooting

### Issue 1: Gradle Sync Failed

**Error:** `Could not resolve dependencies`

**Solution:**
```bash
# Update Gradle wrapper
./gradlew wrapper --gradle-version=8.0

# Sync again
./gradlew build --refresh-dependencies
```

### Issue 2: NDK Not Found

**Error:** `NDK not configured`

**Solution:**
```bash
# Install NDK via SDK Manager
sdkmanager --install "ndk;21.4.7075529"

# Or set path in local.properties
echo "ndk.dir=/path/to/ndk" >> local.properties
```

### Issue 3: Build Tools Version Mismatch

**Error:** `Failed to find Build Tools revision 30.0.3`

**Solution:**
```bash
# Install specific build tools version
sdkmanager --install "build-tools;30.0.3"

# Or update build.gradle to use installed version
# buildToolsVersion "30.0.3" → "33.0.0"
```

### Issue 4: ProGuard Errors

**Error:** `ProGuard configuration errors`

**Solution:**
```bash
# Disable ProGuard temporarily for testing
# In app/build.gradle:
buildTypes {
    release {
        minifyEnabled false  // Change to false
        shrinkResources false
    }
}
```

### Issue 5: Native Library Not Found

**Error:** `java.lang.UnsatisfiedLinkError: dlopen failed`

**Solution:**
```bash
# Verify native library is built
ls app/build/intermediates/cmake/release/obj/

# Should see arm64-v8a, armeabi-v7a folders with libnative-lib.so

# Clean and rebuild
./gradlew clean
./gradlew assembleRelease
```

### Issue 6: APK Installation Failed

**Error:** `INSTALL_FAILED_UPDATE_INCOMPATIBLE`

**Solution:**
```bash
# Uninstall existing app
adb uninstall com.ctf.secureapp

# Install again
adb install app/build/outputs/apk/release/SecureApp.apk
```

---

## 📦 Release Preparation

### 1. Create Distribution Package

```bash
# Create release directory
mkdir -p release

# Copy APK
cp app/build/outputs/apk/release/SecureApp.apk release/

# Create README for competitors
cat > release/README.txt << 'EOF'
SecureApp - APK Reverse Engineering Challenge

Difficulty: INSANE
Points: 1000
Flag Format: APIIT{...}

Instructions:
1. Install: adb install SecureApp.apk
2. Analyze the APK to find the hidden flag
3. Use any tools necessary
4. Submit the flag in format APIIT{...}

Good luck!
EOF

# Create checksums
cd release
sha256sum SecureApp.apk > SHA256SUMS
md5sum SecureApp.apk > MD5SUMS
cd ..
```

### 2. Verify APK

```bash
# Get APK info
aapt dump badging release/SecureApp.apk | grep -E "package|version"

# Verify signature
apksigner verify --verbose release/SecureApp.apk

# Get file size
ls -lh release/SecureApp.apk
```

### 3. Test on Multiple Devices

```bash
# Test on different architectures
# arm64-v8a (modern phones)
# armeabi-v7a (older phones)
# x86 (emulators)
# x86_64 (emulators)

# Verify all architectures are included
unzip -l release/SecureApp.apk | grep "\.so$"
```

---

## 🚀 Deployment Checklist

- [ ] Build release APK successfully
- [ ] Sign APK with keystore
- [ ] Zipalign APK
- [ ] Verify signature
- [ ] Test on physical device
- [ ] Test on emulator
- [ ] Test correct flag works
- [ ] Test incorrect flag fails
- [ ] Verify anti-debugging works
- [ ] Verify root detection works
- [ ] Check APK size (< 10MB recommended)
- [ ] Generate SHA256 checksum
- [ ] Create distribution package
- [ ] Test installation from scratch
- [ ] Backup keystore securely
- [ ] Document any special requirements

---

## 📊 Build Specifications

| Property | Value |
|----------|-------|
| **Build Tool** | Gradle 8.0+ |
| **Compile SDK** | 33 (Android 13) |
| **Min SDK** | 24 (Android 7.0) |
| **Target SDK** | 33 (Android 13) |
| **NDK Version** | 21.4.7075529+ |
| **Java Version** | 11 or 17 |
| **ProGuard** | Enabled |
| **Minify** | Enabled |
| **Shrink Resources** | Enabled |
| **APK Size** | ~5-8 MB |

---

## 🔐 Security Notes

**⚠️ IMPORTANT:**

1. **Keep Keystore Secure:**
   - Never commit keystore to git
   - Store in secure location
   - Backup keystore (you can't rebuild APK without it)

2. **Passwords:**
   - Use strong passwords for production
   - Change default passwords in scripts
   - Don't hardcode passwords in code

3. **ProGuard Mapping:**
   - Save `mapping.txt` from `app/build/outputs/mapping/release/`
   - Needed to deobfuscate crash reports
   - Keep confidential (helps competitors if leaked)

4. **Source Code:**
   - Never distribute source code before CTF
   - Keep GitHub repo private
   - Only distribute final APK

---

## 📝 Build Logs

Expected output from successful build:

```
> Task :app:compileReleaseJavaWithJavac
> Task :app:compileReleaseKotlin
> Task :app:mergeReleaseNativeLibs
> Task :app:stripReleaseDebugSymbols
> Task :app:transformClassesWithProguardForRelease
> Task :app:packageRelease
> Task :app:assembleRelease

BUILD SUCCESSFUL in 2m 34s
87 actionable tasks: 87 executed
```

---

## 🎯 Quick Reference Commands

```bash
# Clean build
./gradlew clean

# Build debug
./gradlew assembleDebug

# Build release
./gradlew assembleRelease

# Install debug
./gradlew installDebug

# Run app
adb shell am start -n com.ctf.secureapp/.MainActivity

# Uninstall
adb uninstall com.ctf.secureapp

# View logs
adb logcat | grep SecureApp

# Get APK info
aapt dump badging app/build/outputs/apk/release/SecureApp.apk
```

---

## 📚 Additional Resources

- [Android Developer Guide](https://developer.android.com/guide)
- [Gradle Build Guide](https://docs.gradle.org/current/userguide/userguide.html)
- [ProGuard Manual](https://www.guardsquare.com/proguard/manual)
- [NDK Guide](https://developer.android.com/ndk/guides)
- [APK Signing Guide](https://developer.android.com/studio/publish/app-signing)

---

**📱 Happy Building! If you encounter issues, check the troubleshooting section or SOLUTION.md for details.**
