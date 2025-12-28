#include <jni.h>
#include <string>
#include <vector>
#include <android/log.h>

#define LOG_TAG "SecureApp"
#define LOGI(...) __android_log_print(ANDROID_LOG_INFO, LOG_TAG, __VA_ARGS__)

// Anti-debugging: Check for common debugger presence
bool isDebuggerPresent() {
    // Check for TracerPid in /proc/self/status
    FILE* fp = fopen("/proc/self/status", "r");
    if (fp == nullptr) return false;
    
    char line[256];
    bool debugged = false;
    
    while (fgets(line, sizeof(line), fp)) {
        if (strncmp(line, "TracerPid:", 10) == 0) {
            int pid = atoi(line + 10);
            if (pid != 0) {
                debugged = true;
            }
            break;
        }
    }
    
    fclose(fp);
    return debugged;
}

// XOR encryption/decryption
std::string xorEncryptDecrypt(const std::string& data, const std::vector<int>& key) {
    std::string result;
    for (size_t i = 0; i < data.length(); i++) {
        result += (char)(data[i] ^ key[i % key.size()]);
    }
    return result;
}

// Complex flag verification algorithm
bool verifyFlagNative(const std::string& input) {
    // Expected flag: APIIT{N4t1v3_4nd_J4v4_Obfusc4t1on_M4st3r}
    const char expected[] = {
        0x41, 0x50, 0x49, 0x49, 0x54, 0x7B,  // APIIT{
        0x4E, 0x34, 0x74, 0x31, 0x76, 0x33,  // N4t1v3
        0x5F, 0x34, 0x6E, 0x64,              // _4nd
        0x5F, 0x4A, 0x34, 0x76, 0x34,        // _J4v4
        0x5F, 0x4F, 0x62, 0x66, 0x75, 0x73, 0x63, 0x34, 0x74, 0x31, 0x6F, 0x6E,  // _Obfusc4t1on
        0x5F, 0x4D, 0x34, 0x73, 0x74, 0x33, 0x72, 0x7D,  // _M4st3r}
        0x00
    };
    
    // Anti-debugging check
    if (isDebuggerPresent()) {
        return false;
    }
    
    // Length check
    if (input.length() != strlen(expected)) {
        return false;
    }
    
    // Constant-time comparison
    int diff = 0;
    for (size_t i = 0; i < input.length(); i++) {
        diff |= input[i] ^ expected[i];
    }
    
    return diff == 0;
}

// Calculate checksum of input
int calculateChecksum(const std::string& input) {
    int checksum = 0x1337;
    for (size_t i = 0; i < input.length(); i++) {
        checksum ^= input[i];
        checksum = (checksum << 1) | (checksum >> 31);
        checksum += i * 0x42;
    }
    return checksum;
}

// JNI Methods

extern "C" JNIEXPORT jstring JNICALL
Java_com_ctf_secureapp_MainActivity_getEncryptedFlag(JNIEnv* env, jobject /* this */) {
    // Return encrypted bonus message
    std::string encrypted = "Congratulations on finding the native code!";
    std::vector<int> key = {0x42, 0x0F, 0x1A, 0x33, 0x7E};
    
    std::string result = xorEncryptDecrypt(encrypted, key);
    return env->NewStringUTF(result.c_str());
}

extern "C" JNIEXPORT jboolean JNICALL
Java_com_ctf_secureapp_MainActivity_verifyFlag(JNIEnv* env, jobject /* this */, jstring input) {
    if (input == nullptr) {
        return JNI_FALSE;
    }
    
    const char* inputStr = env->GetStringUTFChars(input, nullptr);
    std::string inputCpp(inputStr);
    env->ReleaseStringUTFChars(input, inputStr);
    
    bool result = verifyFlagNative(inputCpp);
    return result ? JNI_TRUE : JNI_FALSE;
}

extern "C" JNIEXPORT jintArray JNICALL
Java_com_ctf_secureapp_MainActivity_getDecryptionKey(JNIEnv* env, jobject /* this */) {
    // Return XOR key for decryption
    std::vector<int> key = {0x42, 0x0F, 0x1A, 0x33, 0x7E};
    
    jintArray result = env->NewIntArray(key.size());
    if (result == nullptr) {
        return nullptr;
    }
    
    jint* elements = env->GetIntArrayElements(result, nullptr);
    for (size_t i = 0; i < key.size(); i++) {
        elements[i] = key[i];
    }
    env->ReleaseIntArrayElements(result, elements, 0);
    
    return result;
}

// Additional obfuscated functions to confuse reverse engineers

static int obf_func_1(int a, int b) {
    return ((a ^ 0xDEAD) + (b ^ 0xBEEF)) ^ 0xC0DE;
}

static int obf_func_2(int x) {
    x = (x & 0xAAAAAAAA) >> 1 | (x & 0x55555555) << 1;
    x = (x & 0xCCCCCCCC) >> 2 | (x & 0x33333333) << 2;
    x = (x & 0xF0F0F0F0) >> 4 | (x & 0x0F0F0F0F) << 4;
    return x;
}

static bool obf_func_3(const char* str) {
    int hash = 0x5A5A5A5A;
    while (*str) {
        hash = ((hash << 5) + hash) + *str++;
    }
    return (hash & 0xFFFF) == 0x1234;  // Always false
}

// Fake verification functions to mislead
static bool fake_verify_1(const std::string& input) {
    return input == "APIIT{fake_flag_1}";
}

static bool fake_verify_2(const std::string& input) {
    return input.find("WRONG") != std::string::npos;
}

// Anti-tampering: Check for Frida/Xposed
extern "C" JNIEXPORT jboolean JNICALL
Java_com_ctf_secureapp_MainActivity_checkTampering(JNIEnv* env, jobject /* this */) {
    // Check for Frida server
    FILE* fp = popen("ps | grep frida", "r");
    if (fp) {
        char buf[128];
        if (fgets(buf, sizeof(buf), fp) != nullptr) {
            pclose(fp);
            return JNI_TRUE;  // Frida detected
        }
        pclose(fp);
    }
    
    // Check for Xposed
    try {
        // This would need actual implementation
        // Just a placeholder for now
    } catch (...) {
    }
    
    return JNI_FALSE;
}
