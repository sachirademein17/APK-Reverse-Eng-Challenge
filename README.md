# 🔐 SecureApp - Insane APK Reverse Engineering Challenge

## Challenge Overview

**Category:** Mobile / Reverse Engineering  
**Difficulty:** INSANE (⭐⭐⭐⭐⭐)  
**Points:** 1000  
**Flag:** `APIIT{N4t1v3_4nd_J4v4_Obfusc4t1on_M4st3r}`  
**Estimated Time:** 12-24+ hours  
**Expected Solve Rate:** <5% of teams

## Description

You've obtained a highly secured Android application. Your mission: Reverse engineer the APK to extract the hidden flag. This challenge combines multiple advanced Android reverse engineering techniques that will push your skills to the limit.

## What Makes This Challenge INSANE?

This isn't your typical "decompile and grep for flag" challenge. It includes:

### 🛡️ **Multiple Defense Layers:**
1. **ProGuard Obfuscation** - Aggressive code obfuscation
2. **Native Code (JNI/NDK)** - C++ verification logic
3. **Anti-Debugging** - Debugger detection and prevention
4. **Root Detection** - Checks for rooted devices
5. **Certificate Pinning** - App signature verification
6. **Integrity Checks** - Anti-tampering mechanisms
7. **String Encryption** - All strings are obfuscated
8. **Reflection Abuse** - Dynamic class loading
9. **Control Flow Obfuscation** - Complex program flow
10. **Time-based Checks** - Anti-debugging timing attacks

### 🎯 **Challenge Components:**

- **Java Layer:** MainActivity with obfuscated verification
- **Hidden Java Class:** Reflection-based HiddenCheck
- **Native Layer:** C++ JNI code with flag verification
- **Multiple Verification Stages:**
  - Format check (regex)
  - Length validation
  - Custom algorithm (checksum)
  - Native verification
  - Reflection-based check

## Files Provided

- `SecureApp.apk` - The challenge APK

## Challenge Setup

### For Competitors:

```bash
# Install the APK on device/emulator
adb install SecureApp.apk

# Launch the app
adb shell am start -n com.ctf.secureapp/.MainActivity
```

### Building from Source (For Organizers Only):

```bash
# Prerequisites:
# - Android Studio
# - Android NDK
# - JDK 11+

# Build the APK
cd APK_Challenge
./gradlew assembleRelease

# Output: app/build/outputs/apk/release/app-release.apk
```

## Required Skills

To solve this challenge, you need expertise in:

✅ Android app reverse engineering  
✅ Java/Kotlin decompilation (jadx, jd-gui, etc.)  
✅ Native ARM assembly (for C++ code)  
✅ Frida/Xposed hooking  
✅ APKTool/apktool manipulation  
✅ ProGuard obfuscation understanding  
✅ JNI (Java Native Interface)  
✅ Smali code analysis  
✅ Dynamic instrumentation  
✅ Python scripting for automation  

## Recommended Tools

### Decompilation:
- **jadx** - Java decompiler
- **jadx-gui** - GUI version
- **JD-GUI** - Alternative decompiler
- **Ghidra** - For native code

### Dynamic Analysis:
- **Frida** - Dynamic instrumentation
- **Xposed** - Framework hooks
- **objection** - Frida-based tool

### APK Manipulation:
- **apktool** - APK decompilation/recompilation
- **apksigner** - APK signing
- **zipalign** - APK optimization

### Debugging:
- **Android Studio** - IDE with debugger
- **IDA Pro** - Native code debugging
- **gdb-server** - Remote debugging

### Emulation:
- **Android Studio Emulator**
- **Genymotion**
- **Real device** (recommended)

## Hints (Progressive Release)

### Hint 1 (After 6 hours):
"The flag is split between Java and native code. You'll need to bypass anti-debugging checks."

### Hint 2 (After 12 hours):
"Look for reflection-based verification. The HiddenCheck class holds part of the secret."

### Hint 3 (After 18 hours):
"The native library contains the real verification. Strings are encoded as integer arrays."

### Hint 4 (After 24 hours):
"Use Frida to hook native methods and bypass timing checks. The flag format is APIIT{...}"

## Learning Objectives

Competitors will learn:
- Advanced Android reverse engineering
- ProGuard deobfuscation techniques
- JNI/NDK analysis
- Anti-debugging bypass methods
- Dynamic instrumentation with Frida
- Smali code manipulation
- ARM assembly basics
- Mobile security concepts

## Scoring

- **Base Points:** 1000
- **First Blood:** +150 points (15%)
- **Under 12 hours:** +75 points (7.5%)
- **Under 18 hours:** +50 points (5%)

## Solution Overview (SPOILER - Keep Secret!)

The flag can be extracted by:
1. Decompiling the APK with jadx
2. Analyzing MainActivity.java
3. Finding the HiddenCheck class (loaded via reflection)
4. Extracting flag parts from integer arrays
5. Analyzing native-lib.so with Ghidra
6. Bypassing anti-debugging checks
7. Reconstructing the complete flag

**Complete Flag:** `APIIT{N4t1v3_4nd_J4v4_Obfusc4t1on_M4st3r}`

## Testing

To verify your build works:

```bash
# Install and test
adb install app/build/outputs/apk/release/app-release.apk

# Test with correct flag
adb shell input text "APIIT{N4t1v3_4nd_J4v4_Obfusc4t1on_M4st3r}"

# Or use Frida script to test
frida -U -f com.ctf.secureapp -l test.js
```

## Security Notes

This app includes real security mechanisms that are used in production apps:
- Root detection
- Debugger detection
- Certificate pinning
- Integrity checks

These are for educational purposes and demonstrate real-world mobile app security.

## Deployment

1. Build the release APK
2. Test on multiple devices/emulators
3. Verify all security checks work
4. Upload `app-release.apk` to CTF platform
5. Set up progressive hints
6. Monitor for exploits

## Common Pitfalls

❌ **Don't:**
- Assume simple string search will work
- Skip native code analysis
- Ignore anti-debugging checks
- Try to patch the APK without understanding it

✅ **Do:**
- Use dynamic analysis (Frida)
- Understand ProGuard obfuscation
- Analyze both Java and native layers
- Script your analysis
- Be patient and methodical

## Credits

**Author:** [Your Name]  
**Created:** December 2025  
**For:** APIIT CTF  
**Category:** Mobile Reverse Engineering

---

## ⚠️ IMPORTANT: Files to Keep Secret

DO NOT distribute until after CTF:
- Source code (all .java, .cpp files)
- This README (contains flag)
- Build scripts
- Solution documentation

Only distribute: `SecureApp.apk`

---

**Good luck! You'll need it for this INSANE challenge! 🚀**
