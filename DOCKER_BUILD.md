# 🐳 Docker Build Guide

## Quick Start

### Option 1: Simple Build (Fastest)
```bash
./docker-build-simple.sh
```

### Option 2: Interactive Build (Recommended)
```bash
./build-docker.sh
```

### Option 3: Docker Compose
```bash
docker-compose up
```

---

## Prerequisites

### 1. Install Docker

**Ubuntu/Debian:**
```bash
sudo apt-get update
sudo apt-get install docker.io docker-compose
```

**Fedora:**
```bash
sudo dnf install docker docker-compose
```

**Arch Linux:**
```bash
sudo pacman -S docker docker-compose
```

### 2. Start Docker Service
```bash
sudo systemctl start docker
sudo systemctl enable docker  # Auto-start on boot
```

### 3. Add Your User to Docker Group (Optional but Recommended)
```bash
sudo usermod -aG docker $USER
```
**Note:** Log out and back in for this to take effect.

---

## Build Methods Explained

### Method 1: Simple Script (`docker-build-simple.sh`)
- **Fastest** method
- One-line command
- Uses pre-built Android image
- No interaction required
- **Output:** `app/build/outputs/apk/release/app-release-unsigned.apk`

**Usage:**
```bash
./docker-build-simple.sh
```

### Method 2: Interactive Script (`build-docker.sh`)
- **Recommended** method
- Interactive prompts
- Optional cleaning
- Automatic signing
- Checksum generation
- **Output:** `app/build/outputs/apk/release/SecureApp.apk`

**Usage:**
```bash
./build-docker.sh
```

### Method 3: Docker Compose (`docker-compose.yml`)
- **Best for development**
- Cached builds
- Volume management
- Easy to customize

**Usage:**
```bash
docker-compose build  # First time only
docker-compose run --rm apk-builder
```

---

## Docker Image Details

**Base Image:** `mingc/android-build-box:latest`

**Includes:**
- Android SDK 33
- Android NDK 25.1.8937393
- CMake 3.18+
- Gradle 8.0
- Java 17
- All build tools

**Size:** ~2.5 GB (downloads once, cached for future builds)

---

## Troubleshooting

### Docker Permission Denied
```bash
sudo usermod -aG docker $USER
# Then log out and back in
```

Or run with sudo:
```bash
sudo ./build-docker.sh
```

### Docker Daemon Not Running
```bash
sudo systemctl start docker
```

### Build Fails with "Cannot connect to Docker daemon"
```bash
# Check Docker status
sudo systemctl status docker

# Restart Docker
sudo systemctl restart docker
```

### Gradle Daemon Issues
The scripts use `--no-daemon` flag to avoid daemon issues in containers.

### Out of Disk Space
```bash
# Clean up Docker resources
docker system prune -a

# Remove old build artifacts
rm -rf app/build app/.cxx .gradle
```

---

## Build Times

| Run Type | Time | Notes |
|----------|------|-------|
| First build | 8-12 min | Downloads Docker image + dependencies |
| Subsequent builds | 2-4 min | Uses cached dependencies |
| Clean build | 3-5 min | Rebuilds from scratch |

---

## Output Files

After successful build:

```
app/build/outputs/apk/release/
├── app-release-unsigned.apk    # Unsigned APK
├── SecureApp.apk                # Signed & aligned (if using build-docker.sh)
├── SHA256SUMS                   # Checksum file
└── MD5SUMS                      # Checksum file
```

---

## Advanced Usage

### Custom Docker Build
```bash
# Build with custom Dockerfile
docker build -t secureapp-builder .

# Run custom build
docker run --rm -v $(pwd):/project secureapp-builder
```

### Debug Build
```bash
docker run --rm -it \
    -v $(pwd):/project \
    -w /project \
    mingc/android-build-box:latest \
    bash
    
# Inside container:
./gradlew assembleDebug --stacktrace
```

### Clean Build
```bash
docker run --rm \
    -v $(pwd):/project \
    -w /project \
    mingc/android-build-box:latest \
    ./gradlew clean assembleRelease
```

---

## Signing the APK Manually

If you skipped signing in the build script:

```bash
# Create keystore
keytool -genkey -v \
    -keystore app/secureapp.keystore \
    -alias secureapp \
    -keyalg RSA \
    -keysize 2048 \
    -validity 10000

# Sign APK
jarsigner -verbose \
    -sigalg SHA256withRSA \
    -digestalg SHA-256 \
    -keystore app/secureapp.keystore \
    app/build/outputs/apk/release/app-release-unsigned.apk \
    secureapp

# Align APK (if zipalign is installed)
zipalign -f -v 4 \
    app/build/outputs/apk/release/app-release-unsigned.apk \
    app/build/outputs/apk/release/SecureApp.apk
```

---

## Testing the APK

### Install on Android Device/Emulator
```bash
adb install app/build/outputs/apk/release/SecureApp.apk
```

### Verify Signing
```bash
jarsigner -verify -verbose -certs app/build/outputs/apk/release/SecureApp.apk
```

### Check APK Info
```bash
aapt dump badging app/build/outputs/apk/release/SecureApp.apk
```

---

## Why Docker?

✅ **Consistent builds** - Same environment every time  
✅ **No SDK installation** - Everything in container  
✅ **Reproducible** - Same APK on any machine  
✅ **Isolated** - Doesn't affect your system  
✅ **Fast** - Cached dependencies  
✅ **Professional** - Industry standard for CI/CD  

---

## Next Steps

1. **Build the APK:**
   ```bash
   ./build-docker.sh
   ```

2. **Test the APK:**
   ```bash
   adb install app/build/outputs/apk/release/SecureApp.apk
   ```

3. **Verify the flag:**
   ```
   APIIT{N4t1v3_4nd_J4v4_Obfusc4t1on_M4st3r}
   ```

4. **Distribute to CTF competitors!**

---

## Support

If you encounter issues:
1. Check the troubleshooting section above
2. Review Docker logs: `docker logs <container-id>`
3. Check Gradle logs in `app/build/outputs/logs/`
4. Ensure Docker has enough resources (4GB+ RAM recommended)
