#!/bin/bash

# GitHub Actions Setup Script for APK Challenge

echo "🚀 Setting up GitHub Actions for APK Build"
echo "=========================================="
echo ""

# Check if git is installed
if ! command -v git &> /dev/null; then
    echo "❌ Git is not installed. Please install git first:"
    echo "   sudo apt install git"
    exit 1
fi

echo "✅ Git is installed"
echo ""

# Initialize git if not already
if [ ! -d .git ]; then
    echo "📝 Initializing git repository..."
    git init
    echo "✅ Git repository initialized"
else
    echo "✅ Git repository already exists"
fi

# Add all files
echo ""
echo "📦 Adding files to git..."
git add .

# Commit
echo ""
echo "💾 Creating initial commit..."
git commit -m "INSANE APK CTF Challenge - Complete with GitHub Actions" || echo "⚠️  No changes to commit"

echo ""
echo "=========================================="
echo "✅ Local setup complete!"
echo "=========================================="
echo ""
echo "📋 Next Steps:"
echo ""
echo "1. Create a new repository on GitHub:"
echo "   → Go to https://github.com/new"
echo "   → Repository name: APK_Challenge (or any name)"
echo "   → Make it PRIVATE (to keep source code secret)"
echo "   → Do NOT initialize with README, .gitignore, or license"
echo "   → Click 'Create repository'"
echo ""
echo "2. Connect to GitHub (replace YOUR_USERNAME with your GitHub username):"
echo "   git remote add origin https://github.com/YOUR_USERNAME/APK_Challenge.git"
echo "   git branch -M main"
echo "   git push -u origin main"
echo ""
echo "3. Watch the build:"
echo "   → Go to your repository on GitHub"
echo "   → Click 'Actions' tab"
echo "   → Watch the 'Build Android APK' workflow"
echo "   → Wait ~10 minutes for completion"
echo ""
echo "4. Download the APK:"
echo "   → Click on the completed workflow"
echo "   → Scroll to 'Artifacts' section"
echo "   → Download 'SecureApp-APK'"
echo "   → Extract and you'll have SecureApp.apk!"
echo ""
echo "=========================================="
echo "🎉 Your APK will be built in the cloud!"
echo "=========================================="
echo ""
echo "⚠️  IMPORTANT:"
echo "   - Keep the repository PRIVATE until after CTF"
echo "   - Only distribute the APK file to competitors"
echo "   - All source code and solutions stay secret"
echo ""
echo "Need help? Check GITHUB_ACTIONS_GUIDE.md"
echo ""
