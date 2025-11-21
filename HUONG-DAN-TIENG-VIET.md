# Hướng Dẫn Sử Dụng - Security Scanning Stack

## 🚀 Bắt Đầu Nhanh

### Bước 1: Chuẩn bị source code

```bash
# Tạo thư mục
make setup

# Copy source code cần scan vào thư mục source/
cp -r /path/to/your/project/* source/
```

### Bước 2: Chạy scan

```bash
# Chạy tất cả scanners
make scan
```

Quá trình scan sẽ:
- Quét source code với Semgrep (SAST)
- Tìm secrets với Gitleaks
- Tạo reports trong thư mục `reports/`

### Bước 3: Import vào DefectDojo

```bash
# Import findings vào DefectDojo
make import
```

### Bước 4: Xem báo cáo

```bash
# Tạo báo cáo HTML tiếng Việt (KHUYẾN NGHỊ)
make report-vi

# Hoặc xem trong DefectDojo
make open-defectdojo
```

## 📊 Báo Cáo Tiếng Việt

Báo cáo HTML tiếng Việt (`bao-cao-bao-mat.html`) bao gồm:

### ✅ Tổng quan
- Số lượng lỗ hổng theo mức độ nghiêm trọng
- Statistics và charts đẹp mắt
- Tóm tắt kết quả quét

### ✅ Bảng chi tiết lỗ hổng
Mỗi lỗ hổng có:
- **Mức độ nghiêm trọng:** Critical, High, Medium, Low
- **Loại lỗ hổng:** SQL Injection, Path Traversal, Hardcoded Secrets, etc.
- **File và dòng code:** Vị trí chính xác của lỗ hổng
- **Hướng dẫn fix CỤ THỂ:**
  - Giải thích lỗi
  - Code mẫu SAI
  - Code mẫu ĐÚNG
  - Các bước khắc phục

### ✅ Khuyến nghị hành động
- **Ưu tiên cao:** Cần fix trong 7 ngày
- **Ưu tiên trung bình:** Cần fix trong 30 ngày
- **Quy trình khắc phục:** 5 bước chi tiết

### ✅ Công cụ & tài nguyên
- Danh sách công cụ đã sử dụng
- Links tài liệu tham khảo
- Hướng dẫn scan lại sau khi fix

## 🎯 Ví Dụ Hướng Dẫn Fix

### SQL Injection

**❌ Code Lỗi:**
```java
String query = "SELECT * FROM users WHERE id = '" + userId + "'";
```

**✅ Code Đúng:**
```java
PreparedStatement ps = conn.prepareStatement("SELECT * FROM users WHERE id = ?");
ps.setString(1, userId);
```

**Giải thích:**
- Không nối chuỗi trực tiếp vào SQL query
- Sử dụng Prepared Statements để tránh SQL Injection
- Validate và sanitize input từ user

### Hardcoded Secrets

**❌ Code Lỗi:**
```java
String apiKey = "sk-1234567890abcdef";
```

**✅ Code Đúng:**
```java
String apiKey = System.getenv("API_KEY");
```

**Giải thích:**
- Không lưu API key, password, token trong source code
- Sử dụng environment variables
- Hoặc dùng secret manager (AWS Secrets Manager, Azure Key Vault)

### Path Traversal

**❌ Code Lỗi:**
```java
File file = new File(uploadDir, userInput);
```

**✅ Code Đúng:**
```java
Path basePath = Paths.get(uploadDir).toRealPath();
Path filePath = basePath.resolve(userInput).normalize();
if (!filePath.startsWith(basePath)) {
    throw new SecurityException("Invalid file path");
}
```

**Giải thích:**
- Validate file path không chứa `../` hoặc ký tự đặc biệt
- Chuẩn hóa đường dẫn trước khi sử dụng
- Kiểm tra file path nằm trong thư mục cho phép

## 📋 Quy Trình Khắc Phục

### 1. Review Findings
```bash
# Xem tổng hợp
make show-findings

# Tạo báo cáo chi tiết
make report-vi
```

### 2. Assign Tasks
- Mở DefectDojo: `make open-defectdojo`
- Assign từng finding cho developer phụ trách
- Set deadline và priority

### 3. Fix Code
- Developer fix theo hướng dẫn trong báo cáo
- Code review để đảm bảo fix đúng
- Test kỹ trước khi commit

### 4. Verify Fix
```bash
# Chạy lại scan
make scan

# Import vào DefectDojo
make import

# Kiểm tra findings đã giảm
make show-findings
```

### 5. Deploy
- Deploy code đã fix lên production
- Monitor để đảm bảo không có issue
- Document các thay đổi

## 🛠️ Các Lệnh Hữu Ích

```bash
# Setup ban đầu
make setup                  # Tạo thư mục cần thiết

# Scan
make scan                   # Chạy tất cả scanners
make scan-secrets           # Chỉ scan secrets
make scan-sast              # Chỉ scan SAST
make scan-iac               # Chỉ scan IaC

# Import & View
make import                 # Import vào DefectDojo
make show-findings          # Xem tổng hợp trong terminal
make report-vi              # Tạo báo cáo HTML tiếng Việt
make open-defectdojo        # Mở DefectDojo UI

# Quản lý services
make up                     # Khởi động tất cả services
make down                   # Dừng tất cả services
make status                 # Xem trạng thái services
make clean                  # Dọn dẹp reports

# Test
make test-defectdojo        # Test DefectDojo connection
```

## 📊 Kết Quả Thực Tế

Với WebGoat project (ứng dụng có lỗ hổng cố ý), tools đã tìm thấy:

```
Tổng: 593 lỗ hổng
├── Critical:    0
├── High:      178  ⚠️ CẦN FIX NGAY
├── Medium:    415
└── Low:         0
```

**Các loại lỗ hổng phát hiện:**
- ✅ SQL Injection: 45+ findings
- ✅ Path Traversal: 15+ findings
- ✅ Hardcoded Secrets: 26+ findings (JWT, API keys, passwords)
- ✅ Security Misconfigurations: 141+ findings
- ✅ Weak Cryptography: 20+ findings
- ✅ SSRF/Tainted URL: 10+ findings

## 🎓 Hiểu Về Mức Độ Nghiêm Trọng

### 🔴 Critical (Nghiêm trọng)
- **Mô tả:** Lỗ hổng có thể bị khai thác ngay lập tức, gây thiệt hại nghiêm trọng
- **Ví dụ:** Remote Code Execution, Authentication Bypass
- **Thời gian fix:** Ngay lập tức (24h)

### 🟠 High (Cao)
- **Mô tả:** Lỗ hổng dễ khai thác, có thể gây thiệt hại lớn
- **Ví dụ:** SQL Injection, Path Traversal, Hardcoded Secrets
- **Thời gian fix:** Trong vòng 7 ngày

### 🟡 Medium (Trung bình)
- **Mô tả:** Lỗ hổng cần điều kiện đặc biệt để khai thác
- **Ví dụ:** Security Misconfigurations, Missing Headers
- **Thời gian fix:** Trong vòng 30 ngày

### 🟢 Low (Thấp)
- **Mô tả:** Lỗ hổng khó khai thác hoặc tác động nhỏ
- **Ví dụ:** Information Disclosure
- **Thời gian fix:** Trong vòng 90 ngày

## 💡 Tips & Best Practices

### 1. Scan Thường Xuyên
```bash
# Setup cron job để scan hàng ngày
0 2 * * * cd /path/to/project && make scan && make import
```

### 2. Integrate vào CI/CD
```yaml
# GitLab CI
security_scan:
  stage: test
  script:
    - make scan
    - make import
  artifacts:
    reports:
      junit: reports/*.json
```

### 3. Track Progress
- Sử dụng DefectDojo để track tiến độ fix
- Set SLA cho từng mức độ nghiêm trọng
- Generate reports định kỳ cho management

### 4. Educate Team
- Share báo cáo với team
- Training về secure coding
- Code review focus vào security

### 5. Automate
- Tự động scan sau mỗi commit
- Tự động assign findings
- Tự động notify qua Slack/Email

## 🆘 Troubleshooting

### Vấn đề: Không thấy findings

**Giải pháp:**
```bash
# 1. Kiểm tra reports đã tạo chưa
ls -lh reports/

# 2. Kiểm tra DefectDojo
make test-defectdojo

# 3. Import lại
make import

# 4. Xem trong UI
make open-defectdojo
```

### Vấn đề: Import failed

**Giải pháp:**
```bash
# Check logs
docker compose logs defectdojo

# Restart DefectDojo
docker compose restart defectdojo

# Try import again
make import
```

### Vấn đề: Báo cáo không mở

**Giải pháp:**
```bash
# Mở thủ công
open bao-cao-bao-mat.html

# Hoặc
firefox bao-cao-bao-mat.html

# Hoặc
chrome bao-cao-bao-mat.html
```

## 📚 Tài Liệu Tham Khảo

- [README.md](README.md) - Hướng dẫn tổng quan (English)
- [DEFECTDOJO-UI-GUIDE.md](DEFECTDOJO-UI-GUIDE.md) - Hướng dẫn DefectDojo UI
- [IMPORT-GUIDE.md](IMPORT-GUIDE.md) - Hướng dẫn import findings
- [SCAN-RESULTS.md](SCAN-RESULTS.md) - Kết quả scan chi tiết
- [DEMO.md](DEMO.md) - Demo từng bước

## 🎉 Kết Luận

Tools hoạt động hoàn hảo và đã tìm thấy hàng trăm lỗ hổng thực sự trong source code!

**Bước tiếp theo:**
1. Chạy `make report-vi` để tạo báo cáo tiếng Việt
2. Review từng lỗ hổng trong báo cáo
3. Assign cho team members
4. Fix theo hướng dẫn cụ thể
5. Scan lại để verify

**Chúc bạn fix bugs thành công! 🚀**
