// Frida script to bypass security checks and extract flag
// Usage: frida -U -f com.ctf.secureapp -l frida_bypass.js --no-pause

console.log("[*] SecureApp Frida Bypass Script");
console.log("[*] Starting hooks...\n");

Java.perform(function() {
    console.log("[+] Java environment ready");
    
    // ============================================
    // 1. Bypass Anti-Debugging Checks
    // ============================================
    console.log("[*] Hooking anti-debugging checks...");
    
    try {
        var Debug = Java.use("android.os.Debug");
        
        Debug.isDebuggerConnected.implementation = function() {
            console.log("[!] Debug.isDebuggerConnected() called - returning false");
            return false;
        };
        
        Debug.waitingForDebugger.implementation = function() {
            console.log("[!] Debug.waitingForDebugger() called - returning false");
            return false;
        };
        
        console.log("[+] Anti-debugging bypassed (Java)");
    } catch(e) {
        console.log("[-] Failed to hook Debug: " + e);
    }
    
    // ============================================
    // 2. Bypass Root Detection
    // ============================================
    console.log("[*] Hooking root detection...");
    
    try {
        var MainActivity = Java.use("com.ctf.secureapp.MainActivity");
        
        MainActivity.isRooted.implementation = function() {
            console.log("[!] isRooted() called - returning false");
            return false;
        };
        
        console.log("[+] Root detection bypassed");
    } catch(e) {
        console.log("[-] Failed to hook isRooted: " + e);
    }
    
    // ============================================
    // 3. Bypass Certificate Pinning
    // ============================================
    console.log("[*] Hooking certificate pinning...");
    
    try {
        var MainActivity = Java.use("com.ctf.secureapp.MainActivity");
        
        MainActivity.verifyCertificate.implementation = function() {
            console.log("[!] verifyCertificate() called - returning true");
            return true;
        };
        
        console.log("[+] Certificate pinning bypassed");
    } catch(e) {
        console.log("[-] Failed to hook verifyCertificate: " + e);
    }
    
    // ============================================
    // 4. Hook Verification Functions
    // ============================================
    console.log("[*] Hooking verification functions...");
    
    try {
        var MainActivity = Java.use("com.ctf.secureapp.MainActivity");
        
        // Hook verifyInput
        MainActivity.verifyInput.implementation = function(input) {
            console.log("[!] verifyInput() called with: " + input);
            var result = this.verifyInput(input);
            console.log("[!] verifyInput() returned: " + result);
            return result;
        };
        
        // Hook nativeVerifyFlag
        MainActivity.nativeVerifyFlag.implementation = function(input) {
            console.log("[!] nativeVerifyFlag() called with: " + input);
            var result = this.nativeVerifyFlag(input);
            console.log("[!] nativeVerifyFlag() returned: " + result);
            return result;
        };
        
        console.log("[+] Verification functions hooked");
    } catch(e) {
        console.log("[-] Failed to hook verification: " + e);
    }
    
    // ============================================
    // 5. Extract Flag from HiddenCheck
    // ============================================
    console.log("[*] Extracting flag from HiddenCheck...");
    
    try {
        var HiddenCheck = Java.use("com.ctf.secureapp.HiddenCheck");
        
        // Hook verify method
        HiddenCheck.verify.implementation = function(input) {
            console.log("[!] HiddenCheck.verify() called with: " + input);
            var result = this.verify(input);
            console.log("[!] HiddenCheck.verify() returned: " + result);
            return result;
        };
        
        // Try to extract flag parts
        try {
            // Access private fields via reflection
            var part1Field = HiddenCheck.class.getDeclaredField("part1");
            var part2Field = HiddenCheck.class.getDeclaredField("part2");
            var part3Field = HiddenCheck.class.getDeclaredField("part3");
            var part4Field = HiddenCheck.class.getDeclaredField("part4");
            var part5Field = HiddenCheck.class.getDeclaredField("part5");
            var part6Field = HiddenCheck.class.getDeclaredField("part6");
            
            part1Field.setAccessible(true);
            part2Field.setAccessible(true);
            part3Field.setAccessible(true);
            part4Field.setAccessible(true);
            part5Field.setAccessible(true);
            part6Field.setAccessible(true);
            
            var part1 = Java.array('int', part1Field.get(null));
            var part2 = Java.array('int', part2Field.get(null));
            var part3 = Java.array('int', part3Field.get(null));
            var part4 = Java.array('int', part4Field.get(null));
            var part5 = Java.array('int', part5Field.get(null));
            var part6 = Java.array('int', part6Field.get(null));
            
            function intArrayToString(arr) {
                var str = "";
                for (var i = 0; i < arr.length; i++) {
                    str += String.fromCharCode(arr[i]);
                }
                return str;
            }
            
            var flag = intArrayToString(part1) + 
                      intArrayToString(part2) + 
                      intArrayToString(part3) + 
                      intArrayToString(part4) + 
                      intArrayToString(part5) + 
                      intArrayToString(part6);
            
            console.log("\n" + "=".repeat(60));
            console.log("[+] FLAG EXTRACTED FROM JAVA:");
            console.log("[+] " + flag);
            console.log("=".repeat(60) + "\n");
            
        } catch(e) {
            console.log("[-] Failed to extract flag parts: " + e);
        }
        
        console.log("[+] HiddenCheck hooked");
    } catch(e) {
        console.log("[-] Failed to hook HiddenCheck: " + e);
    }
    
    // ============================================
    // 6. Hook Button Click
    // ============================================
    console.log("[*] Hooking button click...");
    
    try {
        var View = Java.use("android.view.View");
        var OnClickListener = Java.use("android.view.View$OnClickListener");
        
        View.setOnClickListener.implementation = function(listener) {
            if (listener != null) {
                var originalOnClick = listener.onClick;
                listener.onClick = function(v) {
                    console.log("[!] Button clicked!");
                    originalOnClick.call(this, v);
                };
            }
            this.setOnClickListener(listener);
        };
        
        console.log("[+] Button click hooked");
    } catch(e) {
        console.log("[-] Failed to hook button click: " + e);
    }
    
    console.log("\n[*] All hooks installed successfully!");
    console.log("[*] Monitoring app activity...\n");
});

// ============================================
// Native Code Hooks
// ============================================
console.log("[*] Setting up native hooks...");

// Hook native anti-debug check
Interceptor.attach(Module.findExportByName("libnative-lib.so", "_Z16anti_debug_checkv"), {
    onEnter: function(args) {
        console.log("[!] Native anti_debug_check() called");
    },
    onLeave: function(retval) {
        console.log("[!] Native anti_debug_check() returned: " + retval);
        retval.replace(0);  // Return false
        console.log("[!] Native anti_debug_check() forced to return: 0");
    }
});

// Hook native verify function
Interceptor.attach(Module.findExportByName("libnative-lib.so", "Java_com_ctf_secureapp_MainActivity_nativeVerifyFlag"), {
    onEnter: function(args) {
        console.log("[!] Native nativeVerifyFlag() called");
        
        // args[0] = JNIEnv*
        // args[1] = jobject (this)
        // args[2] = jstring (input)
        
        var env = args[0];
        var jstring = args[2];
        
        // Get string from jstring
        var getString = new NativeFunction(
            Module.findExportByName("libart.so", "_ZN3art3JNI13GetStringUTFCharsEP7_JNIEnvP8_jstringPh"),
            'pointer',
            ['pointer', 'pointer', 'pointer']
        );
        
        try {
            var strPtr = getString(env, jstring, ptr(0));
            if (strPtr) {
                var inputStr = strPtr.readCString();
                console.log("[!] Native input: " + inputStr);
            }
        } catch(e) {
            console.log("[-] Failed to read input string: " + e);
        }
    },
    onLeave: function(retval) {
        console.log("[!] Native nativeVerifyFlag() returned: " + retval);
    }
});

// Try to extract flag from native code
setTimeout(function() {
    console.log("\n[*] Attempting to extract flag from native memory...");
    
    try {
        var baseAddr = Module.findBaseAddress("libnative-lib.so");
        console.log("[+] libnative-lib.so base address: " + baseAddr);
        
        // Scan for flag pattern in memory
        Memory.scan(baseAddr, Module.getExportByName("libnative-lib.so", "Java_com_ctf_secureapp_MainActivity_nativeVerifyFlag"), "41 50 49 49 54 7b", {
            onMatch: function(address, size) {
                console.log("[+] Found potential flag at: " + address);
                var flagBytes = Memory.readByteArray(address, 50);
                console.log("[+] Bytes: " + hexdump(flagBytes, { ansi: true }));
            },
            onComplete: function() {
                console.log("[*] Memory scan complete");
            }
        });
    } catch(e) {
        console.log("[-] Failed to scan memory: " + e);
    }
}, 2000);

console.log("[+] Native hooks installed");
console.log("\n" + "=".repeat(60));
console.log("[*] Frida bypass script loaded successfully!");
console.log("[*] Try entering any flag and watch the output");
console.log("=".repeat(60) + "\n");
