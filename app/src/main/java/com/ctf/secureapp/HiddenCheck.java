package com.ctf.secureapp;

/**
 * Hidden verification class - accessed via reflection
 * This class provides an additional verification layer
 */
public class HiddenCheck {
    
    // Obfuscated expected values
    private static final int[] PART1 = {65, 80, 73, 73, 84, 123};  // APIIT{
    private static final int[] PART2 = {78, 52, 116, 49, 118, 51};  // N4t1v3
    private static final int[] PART3 = {95, 52, 110, 100};  // _4nd
    private static final int[] PART4 = {95, 74, 52, 118, 52};  // _J4v4
    private static final int[] PART5 = {95, 79, 98, 102, 117, 115, 99, 52, 116, 49, 111, 110};  // _Obfusc4t1on
    private static final int[] PART6 = {95, 77, 52, 115, 116, 51, 114, 125};  // _M4st3r}
    
    public HiddenCheck() {
        // Anti-tampering: check if this class is loaded correctly
        if (!verifyClassIntegrity()) {
            throw new SecurityException("Class integrity compromised");
        }
    }
    
    public boolean verify(String input) {
        try {
            // Reconstruct expected flag
            String expected = buildExpectedFlag();
            
            // Time-based verification (anti-debugging)
            long start = System.currentTimeMillis();
            boolean result = secureCompare(input, expected);
            long end = System.currentTimeMillis();
            
            // If takes too long, debugger might be attached
            if (end - start > 1000) {
                return false;
            }
            
            return result;
            
        } catch (Exception e) {
            return false;
        }
    }
    
    private String buildExpectedFlag() {
        StringBuilder flag = new StringBuilder();
        
        // Reconstruct from parts
        appendPart(flag, PART1);
        appendPart(flag, PART2);
        appendPart(flag, PART3);
        appendPart(flag, PART4);
        appendPart(flag, PART5);
        appendPart(flag, PART6);
        
        return flag.toString();
    }
    
    private void appendPart(StringBuilder sb, int[] part) {
        for (int c : part) {
            sb.append((char) c);
        }
    }
    
    // Constant-time string comparison (anti-timing attacks)
    private boolean secureCompare(String a, String b) {
        if (a.length() != b.length()) {
            return false;
        }
        
        int result = 0;
        for (int i = 0; i < a.length(); i++) {
            result |= a.charAt(i) ^ b.charAt(i);
        }
        
        return result == 0;
    }
    
    private boolean verifyClassIntegrity() {
        // Simple integrity check
        try {
            String className = this.getClass().getName();
            return className.equals("com.ctf.secureapp.HiddenCheck");
        } catch (Exception e) {
            return false;
        }
    }
    
    // Additional obfuscated methods to confuse decompilers
    private int a(int x, int y) { return x ^ y; }
    private int b(int x, int y) { return x & y; }
    private int c(int x, int y) { return x | y; }
    private int d(int x) { return ~x; }
    private int e(int x, int n) { return x << n; }
    private int f(int x, int n) { return x >> n; }
    
    // Fake flag parts to mislead
    private static final int[] FAKE1 = {70, 65, 75, 69, 123, 116, 104, 105, 115, 95, 105, 115, 95, 110, 111, 116, 95, 116, 104, 101, 95, 102, 108, 97, 103, 125};
    private static final int[] FAKE2 = {65, 80, 73, 73, 84, 123, 119, 114, 111, 110, 103, 95, 102, 108, 97, 103, 125};
    
    private String getFakeFlag1() {
        StringBuilder sb = new StringBuilder();
        appendPart(sb, FAKE1);
        return sb.toString();
    }
    
    private String getFakeFlag2() {
        StringBuilder sb = new StringBuilder();
        appendPart(sb, FAKE2);
        return sb.toString();
    }
}
