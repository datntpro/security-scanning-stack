# Security Scanning Stack

🔒 Hệ thống quét bảo mật source code tự động với Docker Compose

## � Yêuc cầu hệ thống

- Docker & Docker Compose
- 8GB RAM tối thiểu (khuyến nghị 16GB)
- 20GB dung lượng đĩa trống
- macOS, Linux, hoặc Windows với WSL2

## 🚀 Hướng dẫn sử dụng từng bước

### Bước 1: Chuẩn bị môi trường

```bash
# Tạo thư mục cần thiết
make setup

# Copy source code cần scan vào thư mục source/
cp -r /path/to/your/code source/

# Hoặc clone từ git
git clone https://github.com/your/repo source/your-project
```

### Bước 2: Khởi động DefectDojo (Vulnerability Management Platform)

```bash
# Khởi tạo DefectDojo lần đầu tiên
make defectdojo-init

# Đợi khoảng 30-60 giây để DefectDojo khởi động hoàn toàn
```

**Thông tin đăng nhập DefectDojo:**
- URL: http://localhost:8000
- Username: `admin`
- Password: `admin`

### Bước 3: Chạy scan

```bash
# Chạy tất cả scanners (khuyến nghị)
make scan

# Hoặc chạy từng loại scan:
make scan-secrets      # Scan secrets (nhanh - 5s)
make scan-sast         # Scan code vulnerabilities (30s)
make scan-iac          # Scan infrastructure code (20s)
make scan-container    # Scan containers (60s)
make scan-sca          # Scan dependencies (120s)
```

**Kết quả scan sẽ được lưu trong thư mục `reports/`**

### Bước 4: Import kết quả vào DefectDojo

```bash
# Import tất cả scan results
make import
```

Script sẽ tự động:
- ✅ Kiểm tra DefectDojo đang chạy
- ✅ Lấy API token
- ✅ Tạo Product và Engagement
- ✅ Import tất cả reports có trong thư mục `reports/`

### Bước 5: Xem kết quả

**Option 1: DefectDojo Web UI (Khuyến nghị)**
```bash
make open-defectdojo
# Hoặc truy cập: http://localhost:8000
```

**Option 2: Báo cáo HTML tiếng Việt**
```bash
make report-vi
# File: bao-cao-bao-mat.html
```

**Option 3: Xem raw reports**
```bash
ls -lh reports/
cat reports/semgrep-report.json | jq
cat reports/gitleaks-report.json | jq
```

## � ️ Các lệnh thường dùng

```bash
# Quản lý services
make up                    # Khởi động tất cả services
make down                  # Dừng tất cả services
make status                # Xem trạng thái services
make logs                  # Xem logs

# Scan
make scan                  # Chạy tất cả scanners
make scan-secrets          # Chỉ scan secrets
make scan-sast             # Chỉ scan code vulnerabilities
make scan-iac              # Chỉ scan infrastructure code
make scan-container        # Chỉ scan containers
make scan-sca              # Chỉ scan dependencies

# Import & View
make import                # Import vào DefectDojo
make open-defectdojo       # Mở DefectDojo UI
make report-vi             # Tạo báo cáo HTML tiếng Việt

# Cleanup
make clean                 # Xóa reports
make clean-all             # Xóa tất cả (bao gồm volumes)
```

## 📁 Cấu trúc thư mục

```
.
├── compose.yaml                    # Docker Compose configuration
├── Makefile                        # Commands tiện lợi
├── scan-all.sh                     # Script scan tự động
├── import-to-defectdojo.sh        # Script import findings
├── generate-vietnamese-report.sh   # Script tạo báo cáo tiếng Việt
├── nginx.conf                      # Nginx config cho DefectDojo
├── source/                         # Đặt source code cần scan vào đây
├── reports/                        # Kết quả scan
├── README.md                       # Hướng dẫn tiếng Anh (file này)
└── HUONG-DAN-TIENG-VIET.md        # Hướng dẫn tiếng Việt đầy đủ
```

## Các công cụ được tích hợp

### SAST (Static Application Security Testing)
- **SonarQube** (Port 9000) - Phân tích chất lượng code
- **Semgrep** - Phân tích tĩnh đa ngôn ngữ

### DAST (Dynamic Application Security Testing)
- **OWASP ZAP** (Port 8080, 8090) - Penetration testing
- **Nuclei** - Template-based scanner

### Container Security
- **Trivy** - Scan vulnerabilities trong containers
- **Grype** - Vulnerability scanner
- **Dockle** - Container image linter

### IaC Security
- **Checkov** - Scan Terraform, K8s, Dockerfile
- **TFSec** - Terraform security scanner
- **KICS** - IaC security scanner

### Secret Detection
- **Gitleaks** - Phát hiện secrets trong code
- **TruffleHog** - Tìm secrets trong git history

### SCA (Software Composition Analysis)
- **OWASP Dependency-Check** - Scan dependencies
- **Safety** - Python dependencies scanner

### Vulnerability Management Platform
- **DefectDojo** (Port 8000) - Centralized vulnerability management
  - Tổng hợp tất cả scan results
  - Deduplication và risk management
  - Metrics, reporting, và compliance
  - Hỗ trợ 100+ scan formats

## Cách sử dụng

### 1. Chuẩn bị

```bash
# Tạo thư mục source và reports
mkdir -p source reports

# Copy source code cần scan vào thư mục source
cp -r /path/to/your/project/* source/
```

### 2. Khởi động toàn bộ stack

```bash
# Khởi động tất cả services
docker compose up -d

# Xem logs
docker compose logs -f
```

### 3. Chạy scan từng công cụ

#### Scan với Semgrep
```bash
docker compose up semgrep
```

#### Scan với Gitleaks
```bash
docker compose up gitleaks
```

#### Scan với Trivy
```bash
docker compose up trivy
```

#### Scan với Checkov (IaC)
```bash
docker compose up checkov
```

#### Scan với TFSec (Terraform)
```bash
docker compose up tfsec
```

#### Scan với OWASP Dependency-Check
```bash
docker compose up dependency-check
```

#### Scan với Grype
```bash
docker compose up grype
```

#### Scan với TruffleHog
```bash
docker compose up trufflehog
```

#### Scan với KICS
```bash
docker compose up kics
```

### 4. Sử dụng SonarQube

```bash
# Truy cập: http://localhost:9000
# Login mặc định: admin/admin

# Cài đặt SonarScanner và chạy scan
docker run --rm \
  --network security-scan_security-scan \
  -v $(pwd)/source:/usr/src \
  sonarsource/sonar-scanner-cli \
  -Dsonar.projectKey=my-project \
  -Dsonar.sources=. \
  -Dsonar.host.url=http://sonarqube:9000 \
  -Dsonar.login=admin \
  -Dsonar.password=admin
```

### 5. Sử dụng OWASP ZAP

```bash
# Truy cập ZAP UI: http://localhost:8080

# Scan một URL cụ thể
docker exec owasp-zap zap-baseline.py -t https://example.com -r /zap/reports/zap-report.html
```

### 6. Scan Docker Image với Trivy

```bash
docker exec trivy trivy image --format json --output /reports/trivy-image-report.json nginx:latest
```

### 7. Scan Docker Image với Dockle

```bash
docker exec dockle dockle --format json --output /reports/dockle-report.json nginx:latest
```

### 8. Sử dụng DefectDojo (Vulnerability Management)

DefectDojo với giao diện đẹp, đầy đủ CSS và thân thiện!

```bash
# Khởi động DefectDojo
make defectdojo-init

# Mở trong browser
make open-defectdojo

# Hoặc truy cập thủ công: http://localhost:8000
# Username: admin
# Password: admin

# Import tất cả scan results tự động
make import

# Hoặc sử dụng script
bash import-to-defectdojo.sh
```

**Lưu ý**: DefectDojo sử dụng Nginx để serve static files (CSS, JS, images) nên giao diện sẽ đẹp và mượt mà.

**Xem hướng dẫn chi tiết**: [DEFECTDOJO-GUIDE.md](DEFECTDOJO-GUIDE.md)

## Chạy scan toàn bộ và import vào DefectDojo

```bash
# Cách 1: Sử dụng script tự động (Khuyến nghị)
bash scan-all.sh

# Script sẽ:
# 1. Khởi động infrastructure (SonarQube, ZAP, DefectDojo)
# 2. Chạy tất cả scanners
# 3. Hỏi có muốn import vào DefectDojo không

# Cách 2: Sử dụng Makefile
make scan        # Chạy tất cả scans
make import      # Import vào DefectDojo

# Cách 3: Chạy từng bước
make up          # Khởi động services
make scan-secrets    # Scan secrets
make scan-sast       # Scan SAST
make scan-iac        # Scan IaC
make scan-container  # Scan containers
make scan-sca        # Scan dependencies
make import          # Import tất cả vào DefectDojo
```

## Xem kết quả

```bash
# Liệt kê tất cả reports
ls -lh reports/

# Xem report JSON
cat reports/gitleaks-report.json | jq
cat reports/semgrep-report.json | jq
cat reports/trivy-fs-report.json | jq
```

## Dọn dẹp

```bash
# Dừng tất cả services
docker compose down

# Xóa volumes (cẩn thận!)
docker compose down -v

# Xóa reports
rm -rf reports/*
```

## Tùy chỉnh

### Thay đổi cấu hình Semgrep
```bash
# Sử dụng ruleset cụ thể
docker compose run semgrep semgrep --config=p/security-audit /src
```

### Thay đổi cấu hình Gitleaks
```bash
# Tạo file .gitleaks.toml trong thư mục source/
# Gitleaks sẽ tự động sử dụng config này
```

### Scan chỉ một số file types
```bash
docker compose run trivy trivy fs --scanners vuln,secret,misconfig /src
```

## Lưu ý

1. **Performance**: Chạy tất cả tools cùng lúc có thể tốn nhiều tài nguyên
2. **Source Code**: Đảm bảo source code trong thư mục `source/`
3. **Reports**: Tất cả reports được lưu trong thư mục `reports/`
4. **Network**: Tất cả services trong cùng network `security-scan`
5. **Volumes**: Data được persist qua các lần restart

## Troubleshooting

### SonarQube không khởi động
```bash
# Tăng vm.max_map_count (Linux)
sudo sysctl -w vm.max_map_count=262144
```

### Permission denied khi scan
```bash
# Fix permissions
chmod -R 755 source/
chmod -R 777 reports/
```

## � Chii tiết các scanners

### Secret Detection
- **Gitleaks** - Tìm API keys, passwords, tokens trong code
- **TruffleHog** - Tìm secrets trong git history

### SAST (Static Application Security Testing)
- **Semgrep** - Phân tích code đa ngôn ngữ (Java, Python, JS, Go, etc.)
- **SonarQube** - Phân tích chất lượng code và security issues

### Container Security
- **Trivy** - Scan vulnerabilities trong containers và filesystems
- **Grype** - Vulnerability scanner cho containers
- **Dockle** - Container image linter

### IaC Security
- **Checkov** - Scan Terraform, CloudFormation, Kubernetes, Dockerfile
- **TFSec** - Terraform security scanner
- **KICS** - Infrastructure as Code security scanner

### SCA (Software Composition Analysis)
- **OWASP Dependency-Check** - Scan dependencies cho Java, .NET, Python, etc.
- **Safety** - Python dependencies scanner

### DAST (Dynamic Application Security Testing)
- **OWASP ZAP** - Web application penetration testing
- **Nuclei** - Template-based vulnerability scanner

### Vulnerability Management
- **DefectDojo** - Centralized vulnerability management platform
  - Tổng hợp findings từ tất cả scanners
  - Deduplication và risk management
  - Metrics, reporting, compliance

## 🆘 Troubleshooting

### DefectDojo không khởi động

```bash
# Kiểm tra logs
docker compose logs defectdojo

# Restart
docker compose restart defectdojo defectdojo-nginx

# Full reset
docker compose down
make defectdojo-init
```

### Import failed

```bash
# Đảm bảo DefectDojo đang chạy
docker compose ps | grep defectdojo

# Kiểm tra nginx đã start
docker compose ps | grep nginx

# Start nginx nếu chưa chạy
docker compose up -d defectdojo-nginx

# Thử import lại
make import
```

### Port conflict

```bash
# Tìm process đang dùng port
lsof -i :8000

# Hoặc đổi port trong compose.yaml
# defectdojo-nginx:
#   ports:
#     - "8001:8080"
```

### Scan chậm

```bash
# Chạy từng loại scan thay vì tất cả
make scan-secrets  # Nhanh nhất (5s)
make scan-sast     # Trung bình (30s)
make scan-iac      # Trung bình (20s)

# Tăng resources cho Docker
# Docker Desktop → Settings → Resources
# CPU: 4+ cores, Memory: 8+ GB
```

### Permission denied

```bash
# Fix permissions
chmod -R 755 source/
chmod -R 777 reports/
```

## 📚 Tài liệu

### Hướng dẫn sử dụng
- **[QUICKSTART.md](QUICKSTART.md)** - Hướng dẫn nhanh 5 phút ⚡
- **[HUONG-DAN-TIENG-VIET.md](HUONG-DAN-TIENG-VIET.md)** - Hướng dẫn chi tiết từng bước (Tiếng Việt) 🇻🇳
- **[IMPORT-GUIDE.md](IMPORT-GUIDE.md)** - Hướng dẫn import chi tiết 📥

### Tài liệu tham khảo
- [DefectDojo Documentation](https://documentation.defectdojo.com/)
- [Semgrep Rules](https://semgrep.dev/explore)
- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [Trivy Documentation](https://aquasecurity.github.io/trivy/)
- [Gitleaks Documentation](https://github.com/gitleaks/gitleaks)

## 🎯 Workflow hoàn chỉnh

```
1. Setup
   ↓
2. Start DefectDojo (make defectdojo-init)
   ↓
3. Prepare source code (cp code to source/)
   ↓
4. Run scans (make scan)
   ↓
5. Import to DefectDojo (make import)
   ↓
6. Review findings (make open-defectdojo)
   ↓
7. Assign to developers
   ↓
8. Fix vulnerabilities
   ↓
9. Re-scan (make scan)
   ↓
10. Verify fixes (make import)
```

## 📝 License

Private - Internal Use Only
