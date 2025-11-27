# Hướng Dẫn Import Chi Tiết

## Tổng quan

Import là quá trình đưa kết quả scan từ các scanners vào DefectDojo để quản lý tập trung.

## Cách 1: Tự động (Khuyến nghị)

### Sử dụng Makefile

```bash
make import
```

Script sẽ tự động:
1. ✅ Kiểm tra DefectDojo đang chạy
2. ✅ Lấy API token
3. ✅ Tạo/Tìm Product
4. ✅ Tạo Engagement mới
5. ✅ Import tất cả reports

### Sử dụng script trực tiếp

```bash
bash import-to-defectdojo.sh
```

## Cách 2: Thủ công qua Web UI

### Bước 1: Đăng nhập DefectDojo

```
URL: http://localhost:8000
Username: admin
Password: admin
```

### Bước 2: Tạo Product (nếu chưa có)

1. Menu → **Products** → **Add Product**
2. Điền thông tin:
   - **Name:** `My Application`
   - **Description:** `Security scan for my application`
   - **Product Type:** `Web Application`
   - **Business Criticality:** `High`
3. Click **Submit**

### Bước 3: Tạo Engagement

1. Vào Product vừa tạo
2. Click **Add Engagement**
3. Điền thông tin:
   - **Name:** `Security Scan 2024-11-22`
   - **Target Start:** Chọn ngày hôm nay
   - **Target End:** Chọn ngày hôm nay hoặc sau 1 tuần
   - **Engagement Type:** `CI/CD`
   - **Status:** `In Progress`
4. Click **Done**

### Bước 4: Import Scan Results

1. Vào Engagement vừa tạo
2. Click **Import Scan Results**
3. Chọn thông tin:

**Scan Type Mapping (QUAN TRỌNG):**

| Report File | Scan Type trong DefectDojo |
|-------------|----------------------------|
| `gitleaks-report.json` | **Gitleaks Scan** |
| `trufflehog-report.json` | **Trufflehog Scan** |
| `semgrep-report.json` | **Semgrep JSON Report** |
| `trivy-fs-report.json` | **Trivy Scan** |
| `grype-report.json` | **Grype JSON** |
| `dockle-report.json` | **Dockle JSON** |
| `results_checkov.json` | **Checkov Scan** |
| `results.json` (KICS) | **KICS Scan** |
| `dependency-check-report.json` | **Dependency Check Scan** |
| `safety-report.json` | **Safety Scan** |

4. Upload file từ thư mục `reports/`
5. Chọn options:
   - ✅ **Active:** Findings đang active
   - ✅ **Verified:** Findings đã verify
   - **Minimum Severity:** Info (để import tất cả)
6. Click **Import**

### Bước 5: Xem kết quả

1. Vào **Findings** → **All Findings**
2. Filter theo Engagement vừa import
3. Xem chi tiết từng finding

## Cách 3: Sử dụng API

### Lấy API Token

```bash
TOKEN=$(curl -s -X POST http://localhost:8000/api/v2/api-token-auth/ \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"admin"}' | \
  jq -r '.token')

echo $TOKEN
```

### Tạo Product

```bash
PRODUCT_ID=$(curl -s -X POST http://localhost:8000/api/v2/products/ \
  -H "Authorization: Token $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "My Application",
    "description": "Security scan",
    "prod_type": 1
  }' | jq -r '.id')

echo "Product ID: $PRODUCT_ID"
```

### Tạo Engagement

```bash
ENGAGEMENT_ID=$(curl -s -X POST http://localhost:8000/api/v2/engagements/ \
  -H "Authorization: Token $TOKEN" \
  -H "Content-Type: application/json" \
  -d "{
    \"name\": \"Security Scan $(date +%Y-%m-%d)\",
    \"product\": $PRODUCT_ID,
    \"target_start\": \"$(date +%Y-%m-%d)\",
    \"target_end\": \"$(date +%Y-%m-%d)\",
    \"engagement_type\": \"CI/CD\",
    \"status\": \"In Progress\"
  }" | jq -r '.id')

echo "Engagement ID: $ENGAGEMENT_ID"
```

### Import Scan

```bash
# Import Gitleaks
curl -X POST http://localhost:8000/api/v2/import-scan/ \
  -H "Authorization: Token $TOKEN" \
  -F "scan_type=Gitleaks Scan" \
  -F "file=@reports/gitleaks-report.json" \
  -F "engagement=$ENGAGEMENT_ID" \
  -F "active=true" \
  -F "verified=true"

# Import Semgrep
curl -X POST http://localhost:8000/api/v2/import-scan/ \
  -H "Authorization: Token $TOKEN" \
  -F "scan_type=Semgrep JSON Report" \
  -F "file=@reports/semgrep-report.json" \
  -F "engagement=$ENGAGEMENT_ID" \
  -F "active=true" \
  -F "verified=true"

# Import Trivy
curl -X POST http://localhost:8000/api/v2/import-scan/ \
  -H "Authorization: Token $TOKEN" \
  -F "scan_type=Trivy Scan" \
  -F "file=@reports/trivy-fs-report.json" \
  -F "engagement=$ENGAGEMENT_ID" \
  -F "active=true" \
  -F "verified=true"
```

## Troubleshooting

### Error: DefectDojo is not running

**Nguyên nhân:** DefectDojo hoặc nginx chưa khởi động

**Giải pháp:**
```bash
# Kiểm tra services
docker compose ps

# Start DefectDojo và nginx
docker compose up -d defectdojo defectdojo-nginx

# Đợi 10 giây
sleep 10

# Thử lại
make import
```

### Error: Could not get API token

**Nguyên nhân:** 
- DefectDojo chưa khởi động xong
- Credentials sai
- Database chưa sẵn sàng

**Giải pháp:**
```bash
# Đợi DefectDojo khởi động hoàn toàn
docker compose logs defectdojo | tail -20

# Kiểm tra healthcheck
docker inspect defectdojo --format='{{json .State.Health}}' | jq

# Reset password admin
docker exec defectdojo python manage.py shell -c "
from django.contrib.auth.models import User
user = User.objects.get(username='admin')
user.set_password('admin')
user.save()
print('Password reset successfully')
"

# Thử lại
make import
```

### Error: Import failed (HTTP 400)

**Nguyên nhân:**
- File format không đúng
- Scan type không match
- File rỗng hoặc corrupt

**Giải pháp:**
```bash
# 1. Kiểm tra file có hợp lệ không
cat reports/semgrep-report.json | jq . > /dev/null
echo $?  # Phải là 0

# 2. Kiểm tra file có dữ liệu không
ls -lh reports/semgrep-report.json

# 3. Xem error chi tiết
docker compose logs defectdojo-celery-worker | tail -50

# 4. Thử import thủ công qua UI để xem error message
```

### Error: scan_date cannot be in the future

**Nguyên nhân:** Timezone khác nhau giữa client và server

**Giải pháp:** Script đã được fix để dùng ngày hôm qua. Nếu vẫn lỗi:

```bash
# Edit import-to-defectdojo.sh
# Đổi dòng:
SCAN_DATE=$(date -v-1d +%Y-%m-%d)  # macOS
# Thành:
SCAN_DATE=$(date -v-2d +%Y-%m-%d)  # 2 ngày trước
```

### Import chậm

**Nguyên nhân:** File lớn hoặc Celery worker chậm

**Giải pháp:**
```bash
# Scale Celery workers
docker compose up -d --scale defectdojo-celery-worker=3

# Monitor progress
docker compose logs -f defectdojo-celery-worker

# Xem trong UI
# http://localhost:8000/engagement/<ID> → Tests tab
```

## Best Practices

### 1. Tổ chức Products

```
Product = Application/Service
├── Engagement 1 (Sprint 1 - 2024-11-01)
│   ├── Test 1 (Gitleaks)
│   ├── Test 2 (Semgrep)
│   └── Test 3 (Trivy)
├── Engagement 2 (Sprint 2 - 2024-11-15)
│   ├── Test 1 (Gitleaks)
│   └── Test 2 (Semgrep)
```

**Khuyến nghị:**
- 1 application = 1 product
- 1 sprint/release = 1 engagement
- Mỗi scan tool = 1 test

### 2. Naming Convention

**Products:**
- `web-app-frontend`
- `api-backend`
- `mobile-app-ios`

**Engagements:**
- `Sprint 24 - 2024-11-22`
- `Release 1.2.0 - 2024-11-22`
- `Weekly Scan - 2024-W47`

### 3. Scan Frequency

**Critical Apps:**
- Daily scans
- Import immediately
- Review findings same day

**Important Apps:**
- Weekly scans
- Import within 24h
- Review findings within 48h

**Others:**
- Monthly scans
- Import within week
- Review findings within 2 weeks

### 4. Automation

**CI/CD Integration:**

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

**Cron Job:**

```bash
# Daily scan at 2am
0 2 * * * cd /path/to/project && make scan && make import
```

## Monitoring Import

### Xem import status

```bash
# Via API
curl -X GET http://localhost:8000/api/v2/tests/?engagement=$ENGAGEMENT_ID \
  -H "Authorization: Token $TOKEN" | jq

# Via UI
# Menu → Engagements → View engagement → Tests tab
```

### Xem findings

```bash
# Via API
curl -X GET http://localhost:8000/api/v2/findings/?engagement=$ENGAGEMENT_ID \
  -H "Authorization: Token $TOKEN" | jq

# Count findings
curl -X GET http://localhost:8000/api/v2/findings/?engagement=$ENGAGEMENT_ID \
  -H "Authorization: Token $TOKEN" | jq '.count'
```

### Export results

```bash
# Export as CSV
curl -X GET "http://localhost:8000/api/v2/findings/?engagement=$ENGAGEMENT_ID&format=csv" \
  -H "Authorization: Token $TOKEN" > findings.csv

# Export as JSON
curl -X GET "http://localhost:8000/api/v2/findings/?engagement=$ENGAGEMENT_ID" \
  -H "Authorization: Token $TOKEN" | jq > findings.json
```

## Tài liệu tham khảo

- [DefectDojo API Documentation](https://demo.defectdojo.org/api/v2/doc/)
- [Import Scan API](https://documentation.defectdojo.com/integrations/importing/)
- [Supported Parsers](https://documentation.defectdojo.com/integrations/parsers/)
