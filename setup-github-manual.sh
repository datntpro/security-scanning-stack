#!/bin/bash

# Script hướng dẫn push lên GitHub thủ công

echo "=========================================="
echo "Hướng Dẫn Push Lên GitHub Private"
echo "=========================================="
echo ""

# Get current directory name
CURRENT_DIR=$(basename "$PWD")

echo "📁 Thư mục hiện tại: $CURRENT_DIR"
echo ""

echo "🔍 Kiểm tra git status..."
git status --short
echo ""

echo "=========================================="
echo "BƯỚC 1: Tạo Repository trên GitHub"
echo "=========================================="
echo ""
echo "1. Truy cập: https://github.com/new"
echo "2. Điền thông tin:"
echo "   - Repository name: security-scanning-stack"
echo "   - Description: Security Scanning Stack with DefectDojo"
echo "   - Visibility: ✅ Private"
echo "   - Initialize: ❌ KHÔNG chọn gì"
echo "3. Click 'Create repository'"
echo ""
read -p "Nhấn Enter sau khi đã tạo repository trên GitHub..."
echo ""

echo "=========================================="
echo "BƯỚC 2: Nhập GitHub Username"
echo "=========================================="
echo ""
read -p "Nhập GitHub username của bạn: " GITHUB_USER

if [ -z "$GITHUB_USER" ]; then
    echo "❌ Username không được để trống!"
    exit 1
fi

echo ""
echo "=========================================="
echo "BƯỚC 3: Chọn phương thức kết nối"
echo "=========================================="
echo ""
echo "1. SSH (khuyến nghị - nếu đã setup SSH key)"
echo "2. HTTPS (cần username/password hoặc token)"
echo ""
read -p "Chọn (1 hoặc 2): " METHOD

if [ "$METHOD" = "1" ]; then
    REMOTE_URL="git@github.com:$GITHUB_USER/security-scanning-stack.git"
    echo ""
    echo "✅ Sử dụng SSH"
else
    REMOTE_URL="https://github.com/$GITHUB_USER/security-scanning-stack.git"
    echo ""
    echo "✅ Sử dụng HTTPS"
fi

echo ""
echo "=========================================="
echo "BƯỚC 4: Add Remote và Push"
echo "=========================================="
echo ""

# Check if remote already exists
if git remote | grep -q "origin"; then
    echo "⚠️  Remote 'origin' đã tồn tại. Xóa và tạo lại..."
    git remote remove origin
fi

echo "Adding remote..."
git remote add origin "$REMOTE_URL"

echo "Setting branch to main..."
git branch -M main

echo ""
echo "Pushing to GitHub..."
echo ""

if git push -u origin main; then
    echo ""
    echo "=========================================="
    echo "✅ THÀNH CÔNG!"
    echo "=========================================="
    echo ""
    echo "Repository của bạn:"
    echo "🔗 https://github.com/$GITHUB_USER/security-scanning-stack"
    echo ""
    echo "Status: 🔒 Private"
    echo ""
    echo "Clone lại:"
    echo "  git clone $REMOTE_URL"
    echo ""
else
    echo ""
    echo "=========================================="
    echo "❌ Push thất bại!"
    echo "=========================================="
    echo ""
    echo "Có thể do:"
    echo "1. SSH key chưa được setup (nếu dùng SSH)"
    echo "2. Authentication failed (nếu dùng HTTPS)"
    echo "3. Repository chưa được tạo trên GitHub"
    echo ""
    echo "Xem hướng dẫn chi tiết:"
    echo "  cat PUSH-TO-GITHUB.md"
    echo ""
    exit 1
fi
