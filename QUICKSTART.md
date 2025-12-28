# 🎯 SecureApp Challenge - Quick Start Guide

## Overview

**SecureApp** is an INSANE difficulty APK reverse engineering challenge featuring:
- ⭐⭐⭐⭐⭐ Difficulty Level
- 1000 Points
- Multiple security layers
- Java + Native code analysis required
- Estimated solve time: 12-24+ hours

## Flag

```
APIIT{N4t1v3_4nd_J4v4_Obfusc4t1on_M4st3r}
```

---

## Quick Build & Test

### 1. Build APK

```bash
cd APK_Challenge
./build.sh
```

The script will:
- ✅ Clean previous builds
- ✅ Build release APK
- ✅ Create keystore
- ✅ Sign APK
- ✅ Zipalign APK
- ✅ Create release package

**Output:** `release/SecureApp.apk`

### 2. Install & Test

```bash
# Install
adb install release/SecureApp.apk

# Launch
adb shell am start -n com.ctf.secureapp/.MainActivity

# Test with correct flag
adb shell input text "APIIT{N4t1v3_4nd_J4v4_Obfusc4t1on_M4st3r}"
```

### 3. Test with Frida (Optional)

```bash
# Install Frida
pip3 install frida-tools

# Run bypass script
frida -U -f com.ctf.secureapp -l frida_bypass.js --no-pause
```

---

## Challenge Structure

```
APK_Challenge/
├── app/
│   ├── src/
│   │   ├── main/
│   │   │   ├── java/com/ctf/secureapp/
│   │   │   │   ├── MainActivity.java       # Main app logic
│   │   │   │   └── HiddenCheck.java        # Reflection-based verification
│   │   │   ├── cpp/
│   │   │   │   └── native-lib.cpp          # JNI native code
│   │   │   └── res/                        # Resources
│   │   └── build.gradle                    # App build config
│   ├── proguard-rules.pro                  # Obfuscation rules
│   └── CMakeLists.txt                      # Native build
├── build.gradle                            # Project config
├── settings.gradle
├── build.sh                                # Automated build script
├── frida_bypass.js                         # Testing/solution script
├── README.md                               # Full documentation
├── SOLUTION.md                             # Complete solution guide
└── BUILD.md                                # Build instructions
```

---

## Security Features

### Java Layer:
1. **ProGuard Obfuscation** - Aggressive code mangling
2. **Anti-Debugging** - `Debug.isDebuggerConnected()`
3. **Root Detection** - Checks for su binary, test-keys
4. **Certificate Pinning** - App signature verification
5. **Reflection** - Dynamic class loading (`HiddenCheck`)
6. **String Obfuscation** - Integer array encoding
7. **Multi-layer Verification** - 5 verification stages

### Native Layer (C++):
1. **JNI Code** - Native verification logic
2. **Anti-Debugging** - `ptrace` and timing checks
3. **XOR Encryption** - Flag encoded with XOR 0x55
4. **Obfuscated Functions** - Hidden function names
5. **String Encoding** - No plain text strings

---

## Solution Overview

### Step 1: Decompile APK
```bash
jadx SecureApp.apk -d decompiled
```

### Step 2: Find Hidden Class
Look for `HiddenCheck` loaded via reflection in `MainActivity`

### Step 3: Extract Java Flag Parts
Decode integer arrays in `HiddenCheck.java`:
```python
part1 = [65, 80, 73, 73, 84, 123]  # "APIIT{"
# ... decode all parts
```

### Step 4: Analyze Native Code
```bash
ghidra libnative-lib.so
# Find Java_com_ctf_secureapp_MainActivity_nativeVerifyFlag
# Extract XOR-encoded flag
```

### Step 5: Decode Native Flag
```python
encoded = [0x14, 0x05, ...]  # XOR with 0x55
decoded = ''.join(chr(b ^ 0x55) for b in encoded)
```

**Full Solution:** See `SOLUTION.md`

---

## Hints (Progressive)

1. **After 6 hours:** Flag is split between Java and native code
2. **After 12 hours:** Look for reflection-based verification (HiddenCheck)
3. **After 18 hours:** Native library contains XOR-encoded strings
4. **After 24 hours:** Use Frida to bypass anti-debugging

---

## File Checklist for Distribution

### ✅ Distribute to Competitors:
- `release/SecureApp.apk`
- `release/README.txt`
- `release/SHA256SUMS`

### ❌ Keep Secret (Until After CTF):
- Source code (`*.java`, `*.cpp`)
- Build files (`build.gradle`, `CMakeLists.txt`)
- `README.md` (contains flag)
- `SOLUTION.md` (complete solution)
- `BUILD.md` (build instructions)
- `frida_bypass.js` (solution script)
- Keystore file

---

## Testing Checklist

- [ ] APK builds successfully
- [ ] APK installs on device
- [ ] App launches without crashing
- [ ] Correct flag shows success message
- [ ] Incorrect flag shows error message
- [ ] Anti-debugging works (app detects debugger)
- [ ] Root detection works
- [ ] ProGuard obfuscation applied
- [ ] Native library included
- [ ] All architectures supported
- [ ] Tested on emulator
- [ ] Tested on physical device

---

## Troubleshooting

### Build fails:
```bash
# Clean and rebuild
./gradlew clean
./gradlew assembleRelease
```

### NDK not found:
```bash
# Install NDK
sdkmanager --install "ndk;21.4.7075529"
```

### Installation fails:
```bash
# Uninstall first
adb uninstall com.ctf.secureapp
adb install release/SecureApp.apk
```

### App crashes:
```bash
# View logs
adb logcat | grep AndroidRuntime
```

---

## Points Distribution

| Achievement | Points |
|------------|--------|
| Base solve | 1000 |
| First blood | +150 |
| Under 12h | +75 |
| Under 18h | +50 |
| Writeup | +25 |
| **Maximum** | **1250** |

---

## Required Tools for Competitors

### Essential:
- jadx / jadx-gui
- Frida
- apktool
- ADB

### Recommended:
- Ghidra / IDA Pro
- objection
- Android Studio
- Genymotion

---

## Support

For issues:
1. Check `BUILD.md` for detailed build instructions
2. See `SOLUTION.md` for complete solution
3. Test with `frida_bypass.js` script
4. Contact challenge author

---

## Credits

**Challenge:** SecureApp - INSANE APK Reverse Engineering  
**Author:** [Your Name]  
**CTF:** APIIT CTF  
**Category:** Mobile / Reverse Engineering  
**Year:** 2024

---

**🎉 Good luck solving this INSANE challenge! 🎉**
