# Hướng Dẫn Push Code Lên GitHub Private

## Cách 1: Sử dụng GitHub CLI (Khuyến nghị)

### Bước 1: Cài đặt GitHub CLI

```bash
# macOS
brew install gh

# Linux (Ubuntu/Debian)
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
sudo apt update
sudo apt install gh
```

### Bước 2: Đăng nhập GitHub

```bash
gh auth login
```

Chọn:
- GitHub.com
- HTTPS
- Login with a web browser
- Copy code và paste vào browser

### Bước 3: Push code

```bash
# Chạy script tự động
bash push-to-github.sh
```

Script sẽ:
- ✅ Tạo private repository
- ✅ Add remote origin
- ✅ Push code lên GitHub
- ✅ Hiển thị link repository

## Cách 2: Thủ công qua GitHub Web

### Bước 1: Tạo repository trên GitHub

1. Truy cập: https://github.com/new
2. Điền thông tin:
   - **Repository name:** `security-scanning-stack`
   - **Description:** `Security Scanning Stack with DefectDojo`
   - **Visibility:** ✅ **Private**
   - **Initialize:** ❌ Không chọn (vì đã có code)
3. Click **Create repository**

### Bước 2: Push code

GitHub sẽ hiển thị hướng dẫn. Copy và chạy:

```bash
# Add remote
git remote add origin git@github.com:YOUR_USERNAME/security-scanning-stack.git

# Hoặc dùng HTTPS
git remote add origin https://github.com/YOUR_USERNAME/security-scanning-stack.git

# Push code
git branch -M main
git push -u origin main
```

**Lưu ý:** Thay `YOUR_USERNAME` bằng username GitHub của bạn.

### Bước 3: Verify

Truy cập repository để kiểm tra:
```
https://github.com/YOUR_USERNAME/security-scanning-stack
```

Đảm bảo:
- ✅ Repository là **Private**
- ✅ Có 22 files
- ✅ README.md hiển thị đúng

## Cách 3: Sử dụng GitHub Desktop

### Bước 1: Cài đặt GitHub Desktop

Download từ: https://desktop.github.com/

### Bước 2: Đăng nhập

- Mở GitHub Desktop
- File → Options → Accounts
- Sign in to GitHub.com

### Bước 3: Publish repository

1. File → Add Local Repository
2. Chọn thư mục project
3. Click **Publish repository**
4. ✅ Chọn **Keep this code private**
5. Click **Publish repository**

## Kiểm tra sau khi push

### 1. Verify trên GitHub

```bash
# Mở repository trong browser
gh repo view --web

# Hoặc truy cập thủ công
open https://github.com/YOUR_USERNAME/security-scanning-stack
```

### 2. Kiểm tra visibility

Repository phải có badge **Private** ở góc trên.

### 3. Clone lại để test

```bash
# Clone về thư mục khác để test
cd /tmp
git clone git@github.com:YOUR_USERNAME/security-scanning-stack.git
cd security-scanning-stack
ls -la
```

## Cập nhật code sau này

```bash
# Sau khi sửa code
git add .
git commit -m "Update: mô tả thay đổi"
git push origin main
```

## Quản lý collaborators

### Thêm người khác vào private repo

1. Vào repository trên GitHub
2. Settings → Collaborators
3. Click **Add people**
4. Nhập username hoặc email
5. Chọn role: Read, Write, hoặc Admin

### Qua CLI

```bash
gh repo edit --add-collaborator USERNAME --permission write
```

## Bảo mật

### 1. Đảm bảo .gitignore đúng

File `.gitignore` đã được cấu hình để không commit:
- ✅ Source code trong `source/`
- ✅ Reports trong `reports/`
- ✅ Generated HTML reports
- ✅ API tokens
- ✅ Temporary files

### 2. Kiểm tra không có secrets

```bash
# Scan git history để tìm secrets
docker run --rm -v $(pwd):/src zricethezav/gitleaks:latest detect --source=/src --verbose
```

### 3. Enable branch protection

1. Repository → Settings → Branches
2. Add rule cho `main` branch:
   - ✅ Require pull request reviews
   - ✅ Require status checks to pass
   - ✅ Include administrators

## Troubleshooting

### Lỗi: Permission denied (publickey)

**Giải pháp:** Setup SSH key

```bash
# Generate SSH key
ssh-keygen -t ed25519 -C "your_email@example.com"

# Add to ssh-agent
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519

# Copy public key
cat ~/.ssh/id_ed25519.pub

# Add to GitHub:
# Settings → SSH and GPG keys → New SSH key
```

### Lỗi: Repository already exists

**Giải pháp:**

```bash
# Xóa remote cũ
git remote remove origin

# Add remote mới
git remote add origin git@github.com:YOUR_USERNAME/security-scanning-stack.git

# Push
git push -u origin main
```

### Lỗi: Authentication failed

**Giải pháp:** Dùng Personal Access Token

1. GitHub → Settings → Developer settings → Personal access tokens
2. Generate new token (classic)
3. Chọn scopes: `repo` (full control)
4. Copy token
5. Dùng token làm password khi push

## Tài liệu tham khảo

- [GitHub CLI](https://cli.github.com/)
- [GitHub Desktop](https://desktop.github.com/)
- [Git Documentation](https://git-scm.com/doc)
- [GitHub Docs](https://docs.github.com/)

## Kết luận

Sau khi push thành công, repository của bạn sẽ:
- ✅ Private (chỉ bạn và collaborators thấy được)
- ✅ Có đầy đủ code và documentation
- ✅ Không chứa sensitive data
- ✅ Sẵn sàng để share với team

**Repository URL:**
```
https://github.com/YOUR_USERNAME/security-scanning-stack
```

Thay `YOUR_USERNAME` bằng GitHub username của bạn.
