# 🚀 GitHub Actions Build Guide

## Quick Start

Your Android APK will now build automatically in the cloud using GitHub Actions!

## Setup Steps

### 1. Create a GitHub Repository

```bash
cd /home/sachira/Desktop/APIITCTF/APK_Challenge

# Initialize git (if not already done)
git init

# Add all files
git add .

# Commit
git commit -m "Initial commit: INSANE APK CTF Challenge"

# Create repository on GitHub, then:
git remote add origin https://github.com/YOUR_USERNAME/APK_Challenge.git
git branch -M main
git push -u origin main
```

### 2. Trigger the Build

The build will automatically start when you push. You can also trigger it manually:

1. Go to your repository on GitHub
2. Click on **Actions** tab
3. Click **Build Android APK** workflow
4. Click **Run workflow** button
5. Select branch (main)
6. Click **Run workflow**

### 3. Download the APK

After the build completes (5-10 minutes):

1. Go to **Actions** tab
2. Click on the completed workflow run
3. Scroll down to **Artifacts**
4. Download **SecureApp-APK** (contains the APK + checksums)

## What Gets Built

The workflow will:
- ✅ Set up Java 17
- ✅ Install Android SDK
- ✅ Install Android NDK
- ✅ Build the APK with ProGuard
- ✅ Sign the APK
- ✅ Zipalign for optimization
- ✅ Generate checksums (SHA-256, MD5)
- ✅ Upload as artifact

## Build Artifacts

After the build, you'll get:

```
SecureApp-APK/
├── SecureApp.apk          # Your final APK!
├── SHA256SUMS             # Checksum verification
└── MD5SUMS                # Checksum verification

build-outputs/
├── app-release-unsigned.apk
└── mapping.txt            # ProGuard mapping (save this!)
```

## Workflow Features

### Automatic Triggers:
- ✅ Push to main/master branch
- ✅ Pull requests
- ✅ Manual trigger (workflow_dispatch)

### Build Matrix (Optional):
You can modify the workflow to build for specific architectures or build types.

### Caching:
The workflow uses Gradle caching to speed up subsequent builds.

## Troubleshooting

### Build Fails?

1. **Check the logs:**
   - Go to Actions → Click the failed build → View logs

2. **Common issues:**
   - NDK not found → Workflow installs it automatically
   - Gradle issues → Wrapper is configured correctly
   - Signing issues → Keystore is created automatically

### Need to Rebuild?

Just push a new commit or manually trigger:
```bash
git commit --allow-empty -m "Rebuild APK"
git push
```

## Local Testing vs GitHub Actions

| Feature | Local Build | GitHub Actions |
|---------|-------------|----------------|
| Setup Time | 30-60 min | 0 min |
| Build Time | 5-10 min | 5-10 min |
| Disk Space | 5+ GB | 0 GB |
| SDK Management | Manual | Automatic |
| Clean Build | Manual cleanup | Always clean |
| CI/CD | Manual | Automatic |

## Advanced: Automatic Releases

Want to automatically create releases? Add this to the workflow:

```yaml
- name: Create Release
  if: startsWith(github.ref, 'refs/tags/')
  uses: softprops/action-gh-release@v1
  with:
    files: |
      app/build/outputs/apk/release/SecureApp.apk
      app/build/outputs/apk/release/SHA256SUMS
  env:
    GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

Then create a tag:
```bash
git tag v1.0
git push origin v1.0
```

## Build Status Badge

Add this to your README.md to show build status:

```markdown
![Build Status](https://github.com/YOUR_USERNAME/APK_Challenge/workflows/Build%20Android%20APK/badge.svg)
```

## Security Notes

⚠️ **Important:**
- Don't commit real keystores to public repos
- The workflow creates a temporary keystore for signing
- For production, use GitHub Secrets for keystore credentials
- Keep source code private until after CTF

## Next Steps

1. ✅ Push to GitHub
2. ✅ Wait for build (5-10 min)
3. ✅ Download APK artifact
4. ✅ Test on device/emulator
5. ✅ Distribute to CTF competitors

## Build Time Estimate

| Step | Time |
|------|------|
| Checkout | 5s |
| Setup Java | 10s |
| Setup Android SDK | 30s |
| Install NDK | 60s |
| Gradle build | 3-5 min |
| Sign & zipalign | 5s |
| **Total** | **5-10 min** |

## Cost

**FREE!** 
- GitHub Actions is free for public repositories
- 2,000 minutes/month for private repos (free tier)

---

## Ready to Build?

Run these commands:

```bash
cd /home/sachira/Desktop/APIITCTF/APK_Challenge

# Initialize and push to GitHub
git init
git add .
git commit -m "INSANE APK CTF Challenge - Complete"

# Create repo on GitHub, then:
git remote add origin https://github.com/YOUR_USERNAME/APK_Challenge.git
git branch -M main
git push -u origin main
```

Then watch the magic happen in the Actions tab! ✨

Your APK will be built in the cloud and ready to download in ~10 minutes!

🎉 **No local SDK installation needed!**
