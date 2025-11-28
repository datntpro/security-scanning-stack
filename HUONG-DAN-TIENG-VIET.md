# Hướng Dẫn Sử Dụng Chi Tiết - Security Scanning Stack

## 📋 Yêu cầu hệ thống

- Docker & Docker Compose đã cài đặt
- 8GB RAM tối thiểu (khuyến nghị 16GB)
- 20GB dung lượng đĩa trống
- macOS, Linux, hoặc Windows với WSL2

## 🚀 Hướng dẫn từng bước (Chi tiết)

### BƯỚC 1: Chuẩn bị môi trường

```bash
# 1.1. Tạo thư mục cần thiết
make setup

# Kết quả:
# ✓ Tạo thư mục source/
# ✓ Tạo thư mục reports/
```

```bash
# 1.2. Copy source code cần scan
cp -r /path/to/your/project/* source/

# Hoặc clone từ git
git clone https://github.com/your/repo source/your-project

# Hoặc sử dụng files mẫu có sẵn (để test)
# Files mẫu đã có trong source/ với 50+ lỗ hổng
ls -la source/
```

### BƯỚC 2: Khởi động DefectDojo

DefectDojo là nền tảng quản lý lỗ hổng bảo mật, nơi tổng hợp tất cả kết quả scan.

```bash
# 2.1. Khởi tạo DefectDojo lần đầu tiên
make defectdojo-init

# Quá trình này sẽ:
# - Khởi động PostgreSQL database
# - Khởi động Redis cache
# - Khởi tạo DefectDojo database
# - Tạo admin user
# - Khởi động DefectDojo web server
# - Khởi động Nginx reverse proxy
# - Khởi động Celery workers (background tasks)

# Đợi khoảng 30-60 giây...
```

```bash
# 2.2. Kiểm tra DefectDojo đã sẵn sàng
docker compose ps

# Bạn sẽ thấy:
# ✓ defectdojo            (healthy)
# ✓ defectdojo-nginx      (healthy)
# ✓ defectdojo-postgres   (healthy)
# ✓ defectdojo-redis      (healthy)
# ✓ defectdojo-celery-worker
# ✓ defectdojo-celery-beat
```

```bash
# 2.3. Truy cập DefectDojo
make open-defectdojo

# Hoặc mở browser: http://localhost:8000
# Username: admin
# Password: admin
```

**⚠️ LƯU Ý QUAN TRỌNG:**
- Lần đầu tiên khởi động có thể mất 1-2 phút
- Nếu không truy cập được, chạy: `docker compose logs defectdojo`
- Nếu nginx chưa chạy: `docker compose up -d defectdojo-nginx`

### BƯỚC 3: Chạy scan

Có 2 cách chạy scan:

**Cách 1: Chạy tất cả scanners (Khuyến nghị)**

```bash
# 3.1. Chạy script scan tự động
make scan

# Hoặc
bash scan-all.sh

# Script sẽ chạy tuần tự:
# 1. Secret Detection (Gitleaks, TruffleHog)      ~5 giây
# 2. SAST (Semgrep)                               ~30 giây
# 3. Container Security (Trivy, Grype)            ~60 giây
# 4. IaC Security (Checkov, KICS, Trivy)        ~20 giây
# 5. SCA (Dependency-Check, Safety)               ~120 giây

# Tổng thời gian: ~4-5 phút
```

**Cách 2: Chạy từng loại scan**

```bash
# 3.2a. Scan secrets (nhanh nhất - 5 giây)
make scan-secrets

# Chạy:
# - Gitleaks: Tìm API keys, passwords, tokens
# - TruffleHog: Tìm secrets trong git history

# Kết quả:
# - reports/gitleaks-report.json
# - reports/trufflehog-report.json
```

```bash
# 3.2b. Scan code vulnerabilities (30 giây)
make scan-sast

# Chạy:
# - Semgrep: Phân tích code tìm lỗ hổng
#   + SQL Injection
#   + XSS, Command Injection
#   + Path Traversal
#   + Hardcoded secrets
#   + Weak cryptography
#   + ... và nhiều hơn

# Kết quả:
# - reports/semgrep-report.json
```

```bash
# 3.2c. Scan infrastructure code (20 giây)
make scan-iac

# Chạy:
# - Checkov: Scan Terraform, CloudFormation, K8s, Dockerfile
# - KICS: Infrastructure as Code scanner
# - Trivy: Scan IaC misconfigurations

# Kết quả:
# - reports/results_checkov.json
# - reports/results.json (KICS)
# - reports/trivy-fs-report.json
```

```bash
# 3.2d. Scan containers (60 giây)
make scan-container

# Chạy:
# - Trivy: Scan vulnerabilities trong containers
# - Grype: Vulnerability scanner

# Kết quả:
# - reports/trivy-fs-report.json
# - reports/grype-report.json
```

```bash
# 3.2e. Scan dependencies (120 giây - chậm nhất)
make scan-sca

# Chạy:
# - OWASP Dependency-Check: Scan Java, .NET, Python, Node.js dependencies
# - Safety: Python dependencies scanner

# Kết quả:
# - reports/dependency-check-report.json
# - reports/safety-report.json
```

```bash
# 3.3. Kiểm tra kết quả scan
ls -lh reports/

# Bạn sẽ thấy các file JSON:
# -rw-r--r--  gitleaks-report.json       (45KB)
# -rw-r--r--  semgrep-report.json        (323KB)
# -rw-r--r--  trivy-fs-report.json       (150KB)
# -rw-r--r--  results_checkov.json       (80KB)
# ... và nhiều hơn
```

### BƯỚC 4: Import kết quả vào DefectDojo

```bash
# 4.1. Import tất cả scan results
make import

# Script sẽ tự động:
# ✓ Kiểm tra DefectDojo đang chạy
# ✓ Lấy API token (authentication)
# ✓ Tạo/Tìm Product: "Security Scan Project"
# ✓ Tạo Engagement mới: "Automated Security Scan 2024-11-22"
# ✓ Import từng report với scan type phù hợp:
#   - Gitleaks → "Gitleaks Scan"
#   - Semgrep → "Semgrep JSON Report"
#   - Trivy → "Trivy Scan"
#   - Checkov → "Checkov Scan"
#   - KICS → "KICS Scan"
#   - Grype → "Grype JSON"
#   - Dependency-Check → "Dependency Check Scan"
#   - Safety → "Safety Scan"

# Kết quả:
# ✓ Gitleaks imported successfully
# ✓ Semgrep imported successfully
# ✓ Trivy imported successfully
# ... và nhiều hơn
```

**Xử lý lỗi import:**

```bash
# Nếu import failed, kiểm tra:

# 1. DefectDojo có đang chạy không?
docker compose ps | grep defectdojo

# 2. Nginx có đang chạy không?
docker compose ps | grep nginx

# 3. Có kết nối được không?
curl -s http://localhost:8000/login

# 4. Xem logs
docker compose logs defectdojo
docker compose logs defectdojo-celery-worker

# 5. Restart và thử lại
docker compose restart defectdojo defectdojo-nginx
sleep 10
make import
```

### BƯỚC 5: Xem và phân tích kết quả

Có 3 cách xem kết quả:

**Cách 1: DefectDojo Web UI (Khuyến nghị - Chuyên nghiệp nhất)**

```bash
# 5.1. Mở DefectDojo
make open-defectdojo

# Hoặc: http://localhost:8000
# Login: admin / admin
```

**Trong DefectDojo UI:**

1. **Dashboard** - Trang chủ
   - Tổng số findings
   - Phân loại theo severity (Critical, High, Medium, Low)
   - Charts và trends
   - Top products by findings

2. **Findings → All Findings** - Xem tất cả lỗ hổng
   - Filter theo severity, status, scanner
   - Sort theo date, severity
   - Bulk actions (assign, close, accept risk)
   - Export CSV/JSON

3. **Click vào một finding** - Xem chi tiết
   - Title & Description
   - Severity & CVSS Score
   - File path & Line number
   - CWE/CVE ID
   - Mitigation (cách khắc phục)
   - References (links tham khảo)
   - Notes & Comments
   - History

4. **Products** - Quản lý projects
   - Xem metrics của từng product
   - Engagements (các đợt scan)
   - Tests (scan results)

5. **Metrics** - Báo cáo và thống kê
   - Findings by Severity
   - Findings by Scanner
   - Open vs Closed trends
   - Time to Remediate
   - SLA tracking

**Cách 2: Báo cáo HTML tiếng Việt (Dễ đọc - Có hướng dẫn fix)**

```bash
# 5.2. Tạo báo cáo HTML tiếng Việt
make report-vi

# File được tạo: bao-cao-bao-mat.html
# Tự động mở trong browser
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

## 📊 Sử Dụng DefectDojo

### Truy cập DefectDojo

```bash
# Mở trong browser
make open-defectdojo
# Hoặc: http://localhost:8000
```

**Thông tin đăng nhập:**
- Username: `admin`
- Password: `admin`

### Các chức năng chính

**1. Dashboard**
- Tổng quan findings theo severity
- Charts và metrics
- Trends theo thời gian

**2. Products & Engagements**
- Tổ chức theo ứng dụng/project
- Mỗi sprint/scan = 1 engagement

**3. Findings Management**
- Xem danh sách tất cả lỗ hổng
- Filter theo severity, status, scanner
- Assign cho developers
- Track remediation progress

**4. Import Scan Results**
- Tự động: `make import`
- Thủ công: Findings → Import Scan Results
- Chọn scan type phù hợp:
  - Gitleaks → "Gitleaks Scan"
  - Semgrep → "Semgrep JSON Report"
  - Trivy → "Trivy Scan"
  - Checkov → "Checkov Scan"

**5. Reports**
- Generate PDF/CSV reports
- Executive summaries
- Compliance reports

### Workflow quản lý Finding

1. **Triage**: Review findings mới
2. **Verify**: Xác nhận là lỗ hổng thực
3. **Prioritize**: Ưu tiên Critical/High
4. **Assign**: Giao cho developer
5. **Track**: Theo dõi tiến độ fix
6. **Retest**: Scan lại sau khi fix
7. **Close**: Đóng finding đã fix

## 🆘 Troubleshooting

### DefectDojo không khởi động

```bash
# Check logs
docker compose logs defectdojo

# Restart
docker compose restart defectdojo

# Full reset
docker compose down
docker compose up -d
```

### Import failed

```bash
# Kiểm tra file format
cat reports/semgrep-report.json | jq

# Xem Celery worker logs
docker compose logs defectdojo-celery-worker

# Import thủ công qua UI
# http://localhost:8000 → Findings → Import Scan Results
```

### Scan chậm

```bash
# Chạy từng loại scan
make scan-secrets  # Nhanh nhất
make scan-sast     # Trung bình
make scan-sca      # Chậm nhất

# Tăng resources cho Docker
# Docker Desktop → Settings → Resources
# CPU: 4+ cores, Memory: 8+ GB
```

### Port conflict

```bash
# Tìm process đang dùng port
lsof -i :8000

# Hoặc đổi port trong compose.yaml
# defectdojo:
#   ports:
#     - "8001:8081"
```

### Permission denied

```bash
# Fix permissions
chmod -R 755 source/
chmod -R 777 reports/
```

### Disk full

```bash
# Clean up
make clean
docker system prune -a
docker volume prune
```

## 📚 Tài Liệu Tham Khảo

- [README.md](README.md) - Hướng dẫn tổng quan (English)
- [DefectDojo Documentation](https://documentation.defectdojo.com/)
- [Semgrep Rules](https://semgrep.dev/explore)
- [OWASP Top 10](https://owasp.org/www-project-top-ten/)

## 🎉 Kết Luận

Tools hoạt động hoàn hảo và có thể tìm thấy hàng trăm lỗ hổng thực sự trong source code!

**Bước tiếp theo:**
1. Chạy `make report-vi` để tạo báo cáo tiếng Việt
2. Review từng lỗ hổng trong báo cáo
3. Assign cho team members
4. Fix theo hướng dẫn cụ thể
5. Scan lại để verify

**Chúc bạn fix bugs thành công! 🚀**
