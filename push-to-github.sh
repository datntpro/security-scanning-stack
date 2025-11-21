#!/bin/bash

# Script để push code lên GitHub private repo

set -e

REPO_NAME="security-scanning-stack"
REPO_DESCRIPTION="Security Scanning Stack with DefectDojo - Automated vulnerability scanning and management"

echo "=========================================="
echo "Push to GitHub Private Repository"
echo "=========================================="
echo ""

# Check if gh CLI is installed
if ! command -v gh &> /dev/null; then
    echo "❌ GitHub CLI (gh) chưa được cài đặt!"
    echo ""
    echo "Cài đặt GitHub CLI:"
    echo "  macOS:   brew install gh"
    echo "  Linux:   https://github.com/cli/cli/blob/trunk/docs/install_linux.md"
    echo ""
    echo "Sau khi cài đặt, chạy: gh auth login"
    exit 1
fi

# Check if authenticated
if ! gh auth status &> /dev/null; then
    echo "❌ Chưa đăng nhập GitHub!"
    echo ""
    echo "Chạy lệnh sau để đăng nhập:"
    echo "  gh auth login"
    echo ""
    exit 1
fi

echo "✅ GitHub CLI đã sẵn sàng"
echo ""

# Get GitHub username
GITHUB_USER=$(gh api user -q .login)
echo "GitHub user: $GITHUB_USER"
echo ""

# Create private repo
echo "Đang tạo private repository: $REPO_NAME"
echo ""

gh repo create "$REPO_NAME" \
    --private \
    --description "$REPO_DESCRIPTION" \
    --source=. \
    --remote=origin \
    --push

echo ""
echo "=========================================="
echo "✅ Hoàn tất!"
echo "=========================================="
echo ""
echo "Repository: https://github.com/$GITHUB_USER/$REPO_NAME"
echo "Status: Private ✅"
echo ""
echo "Clone repo:"
echo "  git clone git@github.com:$GITHUB_USER/$REPO_NAME.git"
echo ""
