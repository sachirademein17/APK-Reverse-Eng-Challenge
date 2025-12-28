# SecureApp - INSANE APK Reverse Engineering Challenge

![Build Status](https://github.com/YOUR_USERNAME/APK_Challenge/workflows/Build%20Android%20APK/badge.svg)

## 🔥 Challenge Overview

**Category:** Mobile / Reverse Engineering  
**Difficulty:** INSANE (⭐⭐⭐⭐⭐)  
**Points:** 1000  
**Flag:** `APIIT{...}`  
**Estimated Time:** 12-24+ hours

## 📱 Description

A highly secured Android application with 10+ security layers. Your mission: Reverse engineer the APK to extract the hidden flag.

**Security Mechanisms:**
- ProGuard obfuscation
- Native JNI/NDK code (C++)
- Anti-debugging checks
- Root detection
- Certificate pinning
- String obfuscation
- Reflection-based verification
- XOR encryption
- Integrity checks

## 🏗️ Building

This project uses GitHub Actions for automated builds. No local Android SDK required!

### Option 1: Download Pre-built APK

1. Go to [Actions](../../actions)
2. Click the latest successful build
3. Download **SecureApp-APK** artifact

### Option 2: Build Locally

```bash
# Requires Android SDK + NDK
./build.sh
```

See [BUILD.md](BUILD.md) for detailed instructions.

## 📦 Distribution

**For CTF Competitors:**
- Distribute: `SecureApp.apk` only
- Keep source code confidential until after CTF

**Files in Release:**
```
release/
├── SecureApp.apk
├── README.txt
└── SHA256SUMS
```

## 📚 Documentation

- [README.md](README.md) - Complete challenge documentation
- [SOLUTION.md](SOLUTION.md) - Full solution guide (confidential)
- [BUILD.md](BUILD.md) - Build instructions
- [QUICKSTART.md](QUICKSTART.md) - Quick reference
- [SETUP_GUIDE.md](SETUP_GUIDE.md) - SDK setup guide
- [GITHUB_ACTIONS_GUIDE.md](GITHUB_ACTIONS_GUIDE.md) - CI/CD guide

## 🛠️ For Organizers

### Testing

```bash
# Install APK
adb install SecureApp.apk

# Test with Frida
frida -U -f com.ctf.secureapp -l frida_bypass.js
```

### Verify Flag

The complete flag format is: `APIIT{...}`

See [SOLUTION.md](SOLUTION.md) for the complete flag and solution.

## 🎓 Learning Objectives

- Advanced Android reverse engineering
- ProGuard deobfuscation
- JNI/NDK analysis
- Anti-debugging bypass
- Dynamic instrumentation with Frida
- Mobile security concepts

## ⚠️ Security Notice

This app includes real security mechanisms for educational purposes:
- Anti-debugging
- Root detection
- Certificate pinning
- Integrity checks

## 📊 Challenge Stats

- **Source Files:** 25+
- **Lines of Code:** 3,500+
- **Security Layers:** 10+
- **Expected Solve Rate:** <5%

## 🏆 Scoring

- Base: 1000 points
- First Blood: +150 points
- Speed Bonus (<12h): +75 points
- Speed Bonus (<18h): +50 points
- Writeup Bonus: +25 points

## 📄 License

Created for APIIT CTF. Keep confidential until after the competition.

## 🙏 Credits

**Author:** [Your Name]  
**Event:** APIIT CTF 2025  
**Category:** Mobile Reverse Engineering

---

**⚠️ Confidential:** Do not distribute source code before the CTF!
