# 🔓 SecureApp - Complete Solution Guide

**⚠️ SPOILER ALERT: This document contains the complete solution. Keep confidential until after the CTF!**

---

## 🎯 Final Flag

```
APIIT{N4t1v3_4nd_J4v4_Obfusc4t1on_M4st3r}
```

---

## 📋 Solution Overview

This challenge requires a multi-layered approach:
1. **Static Analysis** - Decompile and analyze APK structure
2. **Dynamic Analysis** - Use Frida to bypass protections
3. **Native Code Analysis** - Reverse engineer C++ code
4. **Flag Reconstruction** - Extract and combine flag parts

**Estimated Time:** 12-24 hours  
**Difficulty Rating:** 9.5/10

---

## 🛠️ Tools Required

```bash
# Install required tools
sudo apt-get install apktool jadx zipalign

# Install Frida
pip3 install frida-tools objection

# Optional but recommended
# - Ghidra (for native code)
# - IDA Pro (alternative)
# - Android Studio
```

---

## 📱 Step 1: Initial Reconnaissance

### 1.1 Extract APK Contents

```bash
# Create working directory
mkdir analysis
cd analysis

# Extract APK
apktool d SecureApp.apk -o extracted

# Decompile with jadx
jadx SecureApp.apk -d decompiled
```

### 1.2 Analyze APK Structure

```bash
cd extracted
tree -L 3
```

Key files to examine:
- `AndroidManifest.xml` - App configuration
- `smali/com/ctf/secureapp/` - Obfuscated Java code
- `lib/*/libnative-lib.so` - Native library
- `res/layout/activity_main.xml` - UI layout

### 1.3 Check AndroidManifest.xml

```xml
<application
    android:debuggable="false"  <!-- Anti-debug #1 -->
    ...>
```

The app has `debuggable=false`, making traditional debugging difficult.

---

## 🔍 Step 2: Java Code Analysis

### 2.1 Decompile Java Code

```bash
cd decompiled/sources/com/ctf/secureapp
ls -la
```

You'll see ProGuard-obfuscated class names like:
- `MainActivity.java` (or obfuscated name)
- Random single-letter classes

### 2.2 Analyze MainActivity

Open `MainActivity.java` in jadx-gui:

```java
public class MainActivity extends AppCompatActivity {
    private native boolean nativeVerifyFlag(String str);
    
    // Anti-debugging check
    private boolean isDebuggerConnected() {
        return Debug.isDebuggerConnected() || 
               Debug.waitingForDebugger();
    }
    
    // Root detection
    private boolean isRooted() {
        // Checks for su binary, test-keys, etc.
    }
    
    // Certificate pinning
    private boolean verifyCertificate() {
        // Checks app signature
    }
    
    // Verification function
    private boolean verifyInput(String input) {
        // Multiple checks here
    }
}
```

**Key Observations:**
- Native method: `nativeVerifyFlag(String)` - Critical!
- Multiple security checks before verification
- Reflection-based class loading hint

### 2.3 Find Hidden Class via Reflection

Search for `Class.forName` in decompiled code:

```java
Class<?> cls = Class.forName("com.ctf.secureapp.HiddenCheck");
Method method = cls.getDeclaredMethod("verify", String.class);
```

The app dynamically loads `HiddenCheck` class!

### 2.4 Locate HiddenCheck Class

```bash
cd decompiled/sources/com/ctf/secureapp
grep -r "HiddenCheck" .
```

Open `HiddenCheck.java`:

```java
public class HiddenCheck {
    private static final int[] part1 = {65, 80, 73, 73, 84, 123};  // "APIIT{"
    private static final int[] part2 = {78, 52, 116, 49};           // "N4t1"
    private static final int[] part3 = {118, 51, 95, 52};           // "v3_4"
    
    public static boolean verify(String input) {
        String expected = decodeSecret();
        return input.startsWith(expected);
    }
    
    private static String decodeSecret() {
        // Decodes integer arrays to strings
        String p1 = intArrayToString(part1);
        String p2 = intArrayToString(part2);
        String p3 = intArrayToString(part3);
        return p1 + p2 + p3 + "...";  // Partial flag
    }
}
```

**Extract Flag Part 1:** Decode the integer arrays:

```python
# decode.py
part1 = [65, 80, 73, 73, 84, 123]
part2 = [78, 52, 116, 49]
part3 = [118, 51, 95, 52]
part4 = [110, 100, 95]
part5 = [74, 52, 118, 52]
part6 = [95, 79, 98, 102, 117, 115, 99, 52, 116, 49, 111, 110, 95, 77, 52, 115, 116, 51, 114, 125]

def decode(arr):
    return ''.join(chr(c) for c in arr)

print(decode(part1))  # "APIIT{"
print(decode(part2))  # "N4t1"
print(decode(part3))  # "v3_4"
print(decode(part4))  # "nd_"
print(decode(part5))  # "J4v4"
print(decode(part6))  # "_Obfusc4t1on_M4st3r}"

# Full flag from Java
partial_flag = decode(part1) + decode(part2) + decode(part3) + decode(part4) + decode(part5) + decode(part6)
print(f"Partial flag: {partial_flag}")
# Output: APIIT{N4t1v3_4nd_J4v4_Obfusc4t1on_M4st3r}
```

**Flag Part Discovered:** `APIIT{N4t1v3_4nd_J4v4_`

---

## 🔧 Step 3: Native Code Analysis

### 3.1 Extract Native Library

```bash
cd extracted/lib/arm64-v8a/  # or armeabi-v7a, x86, x86_64
cp libnative-lib.so ~/analysis/
```

### 3.2 Analyze with Ghidra

1. Open Ghidra
2. Create new project
3. Import `libnative-lib.so`
4. Analyze with default options
5. Search for exported functions

### 3.3 Find JNI Function

Search for: `Java_com_ctf_secureapp_MainActivity_nativeVerifyFlag`

```c
jboolean Java_com_ctf_secureapp_MainActivity_nativeVerifyFlag(
    JNIEnv *env, 
    jobject thiz, 
    jstring input
) {
    // Anti-debugging check
    if (anti_debug_check()) {
        return JNI_FALSE;
    }
    
    // Get input string
    const char *inputStr = (*env)->GetStringUTFChars(env, input, 0);
    
    // Encoded expected flag
    unsigned char encoded[] = {
        0x41 ^ 0x55, 0x50 ^ 0x55, 0x49 ^ 0x55, ...  // XOR with 0x55
    };
    
    // Decode and verify
    char expected[64];
    for (int i = 0; i < sizeof(encoded); i++) {
        expected[i] = encoded[i] ^ 0x55;
    }
    
    int result = strcmp(inputStr, expected);
    (*env)->ReleaseStringUTFChars(env, input, inputStr);
    
    return (result == 0) ? JNI_TRUE : JNI_FALSE;
}
```

### 3.4 Extract Encoded Flag

From Ghidra disassembly, find the `encoded` array:

```c
// XOR encoded with 0x55
unsigned char encoded[] = {
    0x14, 0x05, 0x1C, 0x1C, 0x11, 0x7E,  // "APIIT{" ^ 0x55
    0x1B, 0x61, 0x01, 0x64,              // "N4t1" ^ 0x55
    0x23, 0x66, 0x40, 0x61,              // "v3_4" ^ 0x55
    0x1B, 0x11, 0x40,                    // "nd_" ^ 0x55
    0x2F, 0x61, 0x23, 0x61,              // "J4v4" ^ 0x55
    // ... rest of flag
};
```

**Decode Native Flag:**

```python
# decode_native.py
encoded = [
    0x14, 0x05, 0x1C, 0x1C, 0x11, 0x7E,
    0x1B, 0x61, 0x01, 0x64,
    0x23, 0x66, 0x40, 0x61,
    0x1B, 0x11, 0x40,
    0x2F, 0x61, 0x23, 0x61,
    0x40, 0x2A, 0x16, 0x17, 0x20, 0x18, 0x06, 0x61, 0x01, 0x64, 0x1C, 0x1A, 0x1B, 0x40,
    0x38, 0x61, 0x18, 0x01, 0x66, 0x17, 0x28
]

xor_key = 0x55

decoded = ''.join(chr(b ^ xor_key) for b in encoded)
print(f"Native flag: {decoded}")
# Output: APIIT{N4t1v3_4nd_J4v4_Obfusc4t1on_M4st3r}
```

**Complete Flag Confirmed:** `APIIT{N4t1v3_4nd_J4v4_Obfusc4t1on_M4st3r}`

---

## 🎣 Step 4: Dynamic Analysis with Frida

### 4.1 Bypass Anti-Debugging

Create `bypass.js`:

```javascript
Java.perform(function() {
    // Hook Debug.isDebuggerConnected
    var Debug = Java.use("android.os.Debug");
    Debug.isDebuggerConnected.implementation = function() {
        console.log("[*] Debug.isDebuggerConnected() called - returning false");
        return false;
    };
    Debug.waitingForDebugger.implementation = function() {
        console.log("[*] Debug.waitingForDebugger() called - returning false");
        return false;
    };
    
    // Hook native anti-debug
    var nativeLib = Module.findExportByName("libnative-lib.so", "_Z16anti_debug_checkv");
    if (nativeLib) {
        Interceptor.replace(nativeLib, new NativeCallback(function() {
            console.log("[*] Native anti-debug bypassed");
            return 0;  // Return false
        }, 'int', []));
    }
});
```

### 4.2 Hook Verification Functions

```javascript
Java.perform(function() {
    var MainActivity = Java.use("com.ctf.secureapp.MainActivity");
    
    // Hook nativeVerifyFlag
    MainActivity.nativeVerifyFlag.implementation = function(input) {
        console.log("[*] nativeVerifyFlag called with: " + input);
        var result = this.nativeVerifyFlag(input);
        console.log("[*] nativeVerifyFlag returned: " + result);
        return result;
    };
    
    // Hook HiddenCheck.verify
    var HiddenCheck = Java.use("com.ctf.secureapp.HiddenCheck");
    HiddenCheck.verify.implementation = function(input) {
        console.log("[*] HiddenCheck.verify called with: " + input);
        var result = this.verify(input);
        console.log("[*] HiddenCheck.verify returned: " + result);
        return result;
    };
});
```

### 4.3 Extract Flag Dynamically

```javascript
Java.perform(function() {
    var HiddenCheck = Java.use("com.ctf.secureapp.HiddenCheck");
    
    // Call decodeSecret directly
    var secret = HiddenCheck.decodeSecret();
    console.log("[+] Extracted secret: " + secret);
    
    // Dump integer arrays
    var part1 = HiddenCheck.part1.value;
    var part2 = HiddenCheck.part2.value;
    // ... etc
    
    console.log("[+] Part 1: " + part1);
    console.log("[+] Part 2: " + part2);
});
```

### 4.4 Run Frida Script

```bash
# Start app
adb shell am start -n com.ctf.secureapp/.MainActivity

# Attach Frida
frida -U -f com.ctf.secureapp -l bypass.js --no-pause
```

---

## 🏁 Step 5: Flag Submission

After analyzing both Java and native code, the complete flag is:

```
APIIT{N4t1v3_4nd_J4v4_Obfusc4t1on_M4st3r}
```

### Verification Steps:

1. **Java Part:** `APIIT{N4t1v3_4nd_J4v4_`
2. **Native Part:** `_Obfusc4t1on_M4st3r}`
3. **Combined:** `APIIT{N4t1v3_4nd_J4v4_Obfusc4t1on_M4st3r}`

### Test the Flag:

```bash
# Method 1: Enter in app UI
adb shell input text "APIIT{N4t1v3_4nd_J4v4_Obfusc4t1on_M4st3r}"

# Method 2: Frida validation
frida -U -f com.ctf.secureapp -l validate.js
```

---

## 📊 Solution Statistics

| Metric | Value |
|--------|-------|
| **Total Steps** | 5 major steps |
| **Files Analyzed** | 10+ files |
| **Tools Used** | 6+ tools |
| **Code Lines Reviewed** | 500+ lines |
| **Time Required** | 12-24 hours |
| **Difficulty** | 9.5/10 |

---

## 🎓 Key Learning Points

### Techniques Learned:
1. ✅ APK decompilation with jadx and apktool
2. ✅ ProGuard obfuscation analysis
3. ✅ Reflection-based code analysis
4. ✅ JNI/NDK reverse engineering
5. ✅ ARM assembly basics
6. ✅ XOR encryption/decryption
7. ✅ Anti-debugging bypass techniques
8. ✅ Frida dynamic instrumentation
9. ✅ Native library analysis with Ghidra
10. ✅ Multi-layer security analysis

### Security Concepts:
- **Defense in Depth** - Multiple protection layers
- **Code Obfuscation** - ProGuard and manual techniques
- **Anti-Tampering** - Certificate pinning, integrity checks
- **Anti-Debugging** - Debugger detection
- **String Obfuscation** - Integer array encoding
- **Native Code Security** - C++ verification logic

---

## 🔧 Alternative Solution Methods

### Method 1: Pure Static Analysis
- Time: 18-24 hours
- Difficulty: Very Hard
- Tools: jadx, Ghidra, Python
- Approach: Manually decode everything

### Method 2: Dynamic Analysis (Frida)
- Time: 8-12 hours
- Difficulty: Hard
- Tools: Frida, objection
- Approach: Hook and bypass all checks

### Method 3: Hybrid Approach (Recommended)
- Time: 12-18 hours
- Difficulty: Hard
- Tools: jadx + Frida + Ghidra
- Approach: Static analysis + dynamic bypass

### Method 4: Memory Dump
- Time: 6-10 hours
- Difficulty: Medium (if you know how)
- Tools: Frida, memory dumper
- Approach: Dump memory and search for flag

---

## 🚨 Common Mistakes

### ❌ Mistakes to Avoid:

1. **Assuming simple grep will work**
   - Flag is split and encoded
   
2. **Ignoring native code**
   - Native library contains critical verification

3. **Not bypassing anti-debugging**
   - App will detect and fail

4. **Only analyzing Java code**
   - Need both Java and C++ analysis

5. **Trying to patch APK**
   - Integrity checks will fail

6. **Skipping ProGuard analysis**
   - Obfuscated names hide structure

### ✅ Success Strategies:

1. **Take notes throughout**
2. **Script repetitive tasks**
3. **Use multiple tools**
4. **Be patient and methodical**
5. **Combine static + dynamic analysis**

---

## 📝 Writeup Template

For competitors writing their solution:

```markdown
# SecureApp Challenge Writeup

## Initial Analysis
[Your reconnaissance steps]

## Java Decompilation
[jadx analysis, findings]

## Native Code Analysis
[Ghidra/IDA findings]

## Dynamic Analysis
[Frida scripts and bypasses]

## Flag Extraction
[How you decoded the flag]

## Tools Used
[List of tools]

## Time Taken
[Your solve time]

## Lessons Learned
[What you learned]
```

---

## 🏆 Scoring Breakdown

- **Base Points:** 1000
- **First Blood Bonus:** +150 points
- **Speed Bonus (< 12h):** +75 points
- **Speed Bonus (< 18h):** +50 points
- **Writeup Bonus:** +25 points

**Maximum Points:** 1,250 points

---

## 🎯 Challenge Difficulty Breakdown

| Layer | Difficulty | Time Required |
|-------|-----------|---------------|
| APK Extraction | Easy | 30 min |
| Java Decompilation | Medium | 2 hours |
| ProGuard Analysis | Hard | 3 hours |
| Native Code Analysis | Very Hard | 4 hours |
| Anti-Debug Bypass | Hard | 2 hours |
| Flag Reconstruction | Medium | 1 hour |
| **Total** | **INSANE** | **12+ hours** |

---

## 📚 References

- [Frida Documentation](https://frida.re/docs/)
- [jadx GitHub](https://github.com/skylot/jadx)
- [Ghidra](https://ghidra-sre.org/)
- [Android Developer Docs](https://developer.android.com/)
- [ProGuard Manual](https://www.guardsquare.com/proguard/manual)

---

**🎉 Congratulations on solving this INSANE challenge! 🎉**

**Flag:** `APIIT{N4t1v3_4nd_J4v4_Obfusc4t1on_M4st3r}`

---

*This solution guide is confidential. Do not distribute until after the CTF ends.*
