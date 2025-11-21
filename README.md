# Security Scanning Stack với Docker Compose

Stack này tích hợp các công cụ opensource nổi tiếng để scan source code toàn diện.

## Cấu trúc thư mục

```
.
├── compose.yaml          # File Docker Compose chính
├── source/              # Đặt source code cần scan vào đây
├── reports/             # Kết quả scan sẽ được lưu ở đây
└── README.md           # File này
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

## Tài liệu tham khảo

- [SonarQube](https://docs.sonarqube.org/)
- [Semgrep](https://semgrep.dev/docs/)
- [OWASP ZAP](https://www.zaproxy.org/docs/)
- [Trivy](https://aquasecurity.github.io/trivy/)
- [Gitleaks](https://github.com/gitleaks/gitleaks)
- [Checkov](https://www.checkov.io/1.Welcome/What%20is%20Checkov.html)
