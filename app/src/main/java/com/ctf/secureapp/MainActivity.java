package com.ctf.secureapp;

import android.app.Activity;
import android.os.Bundle;
import android.widget.Button;
import android.widget.EditText;
import android.widget.TextView;
import android.widget.Toast;
import android.content.Context;
import android.content.pm.PackageManager;
import android.content.pm.Signature;
import android.os.Debug;
import java.io.File;
import java.security.MessageDigest;
import java.util.Arrays;

/**
 * Main Activity - Heavily obfuscated APK challenge
 * This challenge includes:
 * - Native code (JNI)
 * - Anti-debugging
 * - Root detection
 * - Certificate pinning
 * - Custom encryption
 * - Obfuscated control flow
 * - String encryption
 * - Reflection abuse
 */
public class MainActivity extends Activity {
    
    // Native library
    static {
        System.loadLibrary("native-lib");
    }
    
    // Native methods (implemented in C++)
    public native String getEncryptedFlag();
    public native boolean verifyFlag(String input);
    public native int[] getDecryptionKey();
    
    private EditText flagInput;
    private Button verifyButton;
    private TextView resultText;
    private TextView hintText;
    
    // Obfuscated strings
    private static final int[] O1 = {69, 110, 116, 101, 114, 32, 102, 108, 97, 103};
    private static final int[] O2 = {86, 101, 114, 105, 102, 121};
    private static final int[] O3 = {67, 111, 114, 114, 101, 99, 116, 33, 32, 89, 111, 117, 32, 102, 111, 117, 110, 100, 32, 116, 104, 101, 32, 102, 108, 97, 103, 33};
    private static final int[] O4 = {73, 110, 99, 111, 114, 114, 101, 99, 116, 33, 32, 84, 114, 121, 32, 97, 103, 97, 105, 110};
    
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        
        // Anti-debugging checks
        if (isDebuggerAttached()) {
            android.os.Process.killProcess(android.os.Process.myPid());
            return;
        }
        
        // Root detection
        if (isDeviceRooted()) {
            showToast("Rooted device detected. Exiting.");
            finish();
            return;
        }
        
        // Certificate pinning check
        if (!verifyCertificate()) {
            showToast("App signature verification failed!");
            finish();
            return;
        }
        
        // Initialize UI
        initializeUI();
        
        // Set up listeners
        setupListeners();
        
        // Perform integrity check in background
        new Thread(() -> performIntegrityCheck()).start();
    }
    
    private void initializeUI() {
        setContentView(R.layout.activity_main);
        
        flagInput = findViewById(R.id.flagInput);
        verifyButton = findViewById(R.id.verifyButton);
        resultText = findViewById(R.id.resultText);
        hintText = findViewById(R.id.hintText);
        
        flagInput.setHint(d(O1));
        verifyButton.setText(d(O2));
        
        // Set hint
        hintText.setText(getObfuscatedHint());
    }
    
    private void setupListeners() {
        verifyButton.setOnClickListener(v -> {
            String input = flagInput.getText().toString().trim();
            
            if (input.isEmpty()) {
                showToast("Please enter a flag");
                return;
            }
            
            // Verify flag through multiple layers
            if (verifyFlagMultiLayer(input)) {
                resultText.setText(d(O3));
                showToast("Congratulations!");
                revealSecret();
            } else {
                resultText.setText(d(O4));
                showToast("Try harder!");
            }
        });
    }
    
    private boolean verifyFlagMultiLayer(String input) {
        // Layer 1: Format check
        if (!input.matches("^APIIT\\{[A-Za-z0-9_]+\\}$")) {
            return false;
        }
        
        // Layer 2: Length check (obfuscated)
        if (input.length() != (0x2A ^ 0x17)) {
            return false;
        }
        
        // Layer 3: Custom algorithm check
        if (!customAlgorithmCheck(input)) {
            return false;
        }
        
        // Layer 4: Native verification
        if (!verifyFlag(input)) {
            return false;
        }
        
        // Layer 5: Reflection-based check
        if (!reflectionCheck(input)) {
            return false;
        }
        
        return true;
    }
    
    private boolean customAlgorithmCheck(String input) {
        try {
            // Extract content between braces
            String content = input.substring(6, input.length() - 1);
            
            // Complex checksum algorithm
            int checksum = 0;
            for (int i = 0; i < content.length(); i++) {
                int c = content.charAt(i);
                checksum += c * (i + 1);
                checksum ^= (c << (i % 8));
                checksum = Integer.rotateLeft(checksum, 3);
            }
            
            // Expected checksum (obfuscated)
            int expected = 0x4E7A ^ 0x12B4 ^ 0xF00D ^ 0xBEEF;
            return (checksum & 0xFFFFFF) == (expected & 0xFFFFFF);
            
        } catch (Exception e) {
            return false;
        }
    }
    
    private boolean reflectionCheck(String input) {
        try {
            // Use reflection to call hidden method
            Class<?> clazz = Class.forName(d(new int[]{99, 111, 109, 46, 99, 116, 102, 46, 115, 101, 99, 117, 114, 101, 97, 112, 112, 46, 72, 105, 100, 100, 101, 110, 67, 104, 101, 99, 107}));
            Object instance = clazz.newInstance();
            java.lang.reflect.Method method = clazz.getDeclaredMethod("verify", String.class);
            method.setAccessible(true);
            return (Boolean) method.invoke(instance, input);
        } catch (Exception e) {
            return false;
        }
    }
    
    private String getObfuscatedHint() {
        StringBuilder hint = new StringBuilder();
        int[] h = {72, 105, 110, 116, 58, 32, 84, 104, 101, 32, 102, 108, 97, 103, 32, 105, 115, 32, 115, 112, 108, 105, 116, 32, 98, 101, 116, 119, 101, 101, 110, 32, 74, 97, 118, 97, 32, 97, 110, 100, 32, 110, 97, 116, 105, 118, 101, 32, 99, 111, 100, 101};
        for (int c : h) {
            hint.append((char) c);
        }
        return hint.toString();
    }
    
    private void revealSecret() {
        // Decrypt and reveal additional secret
        String encrypted = getEncryptedFlag();
        int[] key = getDecryptionKey();
        String decrypted = decryptWithKey(encrypted, key);
        
        Toast.makeText(this, "Secret: " + decrypted, Toast.LENGTH_LONG).show();
    }
    
    private String decryptWithKey(String encrypted, int[] key) {
        StringBuilder result = new StringBuilder();
        for (int i = 0; i < encrypted.length(); i++) {
            int c = encrypted.charAt(i);
            int k = key[i % key.length];
            result.append((char) (c ^ k));
        }
        return result.toString();
    }
    
    // Anti-debugging: Check if debugger is attached
    private boolean isDebuggerAttached() {
        return Debug.isDebuggerConnected() || Debug.waitingForDebugger();
    }
    
    // Root detection
    private boolean isDeviceRooted() {
        // Check for common root files
        String[] rootFiles = {
            "/system/app/Superuser.apk",
            "/sbin/su",
            "/system/bin/su",
            "/system/xbin/su",
            "/data/local/xbin/su",
            "/data/local/bin/su",
            "/system/sd/xbin/su",
            "/system/bin/failsafe/su",
            "/data/local/su",
            "/su/bin/su"
        };
        
        for (String file : rootFiles) {
            if (new File(file).exists()) {
                return true;
            }
        }
        
        // Check for root management apps
        String[] rootPackages = {
            "com.noshufou.android.su",
            "com.thirdparty.superuser",
            "eu.chainfire.supersu",
            "com.koushikdutta.superuser",
            "com.zachspong.temprootremovejb",
            "com.ramdroid.appquarantine"
        };
        
        PackageManager pm = getPackageManager();
        for (String pkg : rootPackages) {
            try {
                pm.getPackageInfo(pkg, 0);
                return true;
            } catch (Exception e) {
                // Package not found
            }
        }
        
        // Check for test keys
        String buildTags = android.os.Build.TAGS;
        if (buildTags != null && buildTags.contains("test-keys")) {
            return true;
        }
        
        return false;
    }
    
    // Certificate pinning
    private boolean verifyCertificate() {
        try {
            Signature[] signatures = getPackageManager()
                .getPackageInfo(getPackageName(), PackageManager.GET_SIGNATURES)
                .signatures;
            
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            for (Signature signature : signatures) {
                md.update(signature.toByteArray());
                byte[] digest = md.digest();
                
                // Expected certificate hash (would be set during build)
                // For challenge purposes, we'll accept any valid signature
                if (digest.length > 0) {
                    return true;
                }
            }
        } catch (Exception e) {
            return false;
        }
        return false;
    }
    
    // Integrity check
    private void performIntegrityCheck() {
        try {
            // Check if APK has been tampered
            String apkPath = getPackageCodePath();
            File apkFile = new File(apkPath);
            
            if (!apkFile.exists()) {
                runOnUiThread(() -> {
                    showToast("Integrity check failed!");
                    finish();
                });
            }
            
            // Additional checks can be added here
            
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
    
    // Decode obfuscated strings
    private String d(int[] data) {
        StringBuilder result = new StringBuilder();
        for (int c : data) {
            result.append((char) c);
        }
        return result.toString();
    }
    
    private void showToast(String message) {
        Toast.makeText(this, message, Toast.LENGTH_SHORT).show();
    }
}
