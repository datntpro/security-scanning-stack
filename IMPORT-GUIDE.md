# Import Guide - Hướng dẫn import scan results vào DefectDojo

## Quick Start

```bash
# Chạy scans
make scan

# Import vào DefectDojo
make import
```

## Cách import hoạt động

### 1. Tự động (Khuyến nghị)

Script `import-to-defectdojo.sh` sẽ:

1. **Kiểm tra DefectDojo** đang chạy
2. **Lấy API token** bằng username/password
3. **Tạo/Tìm Product** với tên "Security Scan Project"
4. **Tạo Engagement** mới cho mỗi lần scan
5. **Import tất cả reports** từ thư mục `reports/`

```bash
bash import-to-defectdojo.sh
```

### 2. Thủ công qua UI

1. Đăng nhập vào DefectDojo: http://localhost:8000
2. Tạo Product (nếu chưa có):
   - Menu → Products → Add Product
   - Name: "My Application"
   - Product Type: "Web Application"
3. Tạo Engagement:
   - Vào Product → Add Engagement
   - Name: "Security Scan 2024-11-22"
   - Target Start/End: Chọn ngày
4. Import Scan:
   - Vào Engagement → Import Scan Results
   - Chọn Scan Type và upload file

### 3. Sử dụng API

```bash
# Get API token
TOKEN=$(curl -s -X POST http://localhost:8000/api/v2/api-token-auth/ \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"admin"}' | \
  jq -r '.token')

# Import scan
curl -X POST http://localhost:8000/api/v2/import-scan/ \
  -H "Authorization: Token $TOKEN" \
  -F "scan_type=Semgrep JSON Report" \
  -F "file=@reports/semgrep-report.json" \
  -F "engagement=1" \
  -F "active=true" \
  -F "verified=true" \
  -F "scan_date=2024-11-21"
```

## Scan Type Mapping

Khi import, cần chọn đúng Scan Type:

| Tool | Report File | Scan Type trong DefectDojo |
|------|-------------|----------------------------|
| Gitleaks | `gitleaks-report.json` | `Gitleaks Scan` |
| TruffleHog | `trufflehog-report.json` | `Trufflehog Scan` |
| Semgrep | `semgrep-report.json` | `Semgrep JSON Report` |
| Trivy | `trivy-fs-report.json` | `Trivy Scan` |
| Grype | `grype-report.json` | `Grype JSON` |
| Dockle | `dockle-report.json` | `Dockle JSON` |
| Checkov | `results_checkov.json` | `Checkov Scan` |
| TFSec | `tfsec-report.json` | `Tfsec Scan` |
| KICS | `results.json` | `KICS Scan` |
| Dependency-Check | `dependency-check-report.json` | `Dependency Check Scan` |
| Safety | `safety-report.json` | `Safety Scan` |
| OWASP ZAP | `zap-report.json` | `ZAP Scan` |

## Troubleshooting

### Error: Could not create engagement!

**Nguyên nhân:**
- Product ID không hợp lệ
- Ngày tháng không đúng format
- JSON malformed

**Giải pháp:**

Script đã được fix để:
1. Sử dụng `jq` để parse JSON đúng cách
2. Tự động tính toán ngày tháng đúng
3. Fallback sang existing engagement nếu tạo mới fail

```bash
# Nếu vẫn lỗi, check logs
docker compose logs defectdojo

# Hoặc tạo engagement thủ công qua UI
```

### Error: scan_date cannot be in the future!

**Nguyên nhân:**
- Timezone khác nhau giữa client và server
- DefectDojo server ở timezone khác

**Giải pháp:**

Script đã được fix để dùng ngày hôm qua:
```bash
# macOS
SCAN_DATE=$(date -v-1d +%Y-%m-%d)

# Linux
SCAN_DATE=$(date -d 'yesterday' +%Y-%m-%d)
```

### Error: Import failed (HTTP 400)

**Nguyên nhân:**
- File format không đúng
- Scan type không match
- File rỗng hoặc corrupt

**Giải pháp:**

1. Kiểm tra file:
```bash
cat reports/semgrep-report.json | jq
```

2. Kiểm tra scan type:
```bash
# List available scan types
curl -X GET http://localhost:8000/api/v2/test_types/ \
  -H "Authorization: Token $TOKEN" | jq '.results[].name'
```

3. Xem error chi tiết:
```bash
# Script đã show error message
bash import-to-defectdojo.sh
```

### Error: Import failed (HTTP 401)

**Nguyên nhân:**
- API token không hợp lệ
- Token expired
- Credentials sai

**Giải pháp:**

1. Reset password:
```bash
make defectdojo-init
```

2. Get new token:
```bash
curl -X POST http://localhost:8000/api/v2/api-token-auth/ \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"admin"}'
```

### Error: File not found

**Nguyên nhân:**
- Chưa chạy scan
- Report file ở sai thư mục

**Giải pháp:**

1. Chạy scan trước:
```bash
make scan
```

2. Kiểm tra reports:
```bash
ls -lh reports/
```

### Import chậm

**Nguyên nhân:**
- File lớn
- Celery worker chậm
- Database chậm

**Giải pháp:**

1. Scale celery workers:
```bash
docker compose up -d --scale defectdojo-celery-worker=3
```

2. Check celery logs:
```bash
docker compose logs -f defectdojo-celery-worker
```

3. Monitor progress:
```bash
# Vào DefectDojo UI
# Menu → Engagements → View engagement
# Xem "Tests" tab
```

## Best Practices

### 1. Tổ chức Products

```
Product = Application/Service
├── Engagement 1 (Sprint 1)
│   ├── Test 1 (Gitleaks)
│   ├── Test 2 (Semgrep)
│   └── Test 3 (Trivy)
├── Engagement 2 (Sprint 2)
│   ├── Test 1 (Gitleaks)
│   └── Test 2 (Semgrep)
```

**Khuyến nghị:**
- Một app = một product
- Một sprint/release = một engagement
- Mỗi scan tool = một test

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

### 4. Deduplication

DefectDojo tự động deduplicate:
- Cùng file path + line number
- Cùng CWE/CVE ID
- Cùng hash

**Lợi ích:**
- Giảm noise
- Focus vào findings mới
- Track remediation progress

### 5. Workflow

```
1. Run Scans
   ↓
2. Import to DefectDojo
   ↓
3. Triage Findings (24h)
   ↓
4. Assign to Developers
   ↓
5. Track Remediation
   ↓
6. Retest & Close
   ↓
7. Generate Report
```

## Advanced Usage

### Import với custom parameters

```bash
curl -X POST http://localhost:8000/api/v2/import-scan/ \
  -H "Authorization: Token $TOKEN" \
  -F "scan_type=Semgrep JSON Report" \
  -F "file=@reports/semgrep-report.json" \
  -F "engagement=1" \
  -F "active=true" \
  -F "verified=false" \
  -F "scan_date=2024-11-21" \
  -F "minimum_severity=High" \
  -F "close_old_findings=true" \
  -F "push_to_jira=true" \
  -F "tags=production,critical"
```

### Batch import

```bash
#!/bin/bash
for file in reports/*.json; do
  filename=$(basename "$file")
  scan_type="Semgrep JSON Report"  # Adjust per file
  
  curl -X POST http://localhost:8000/api/v2/import-scan/ \
    -H "Authorization: Token $TOKEN" \
    -F "scan_type=$scan_type" \
    -F "file=@$file" \
    -F "engagement=1"
  
  echo "Imported $filename"
done
```

### CI/CD Integration

**GitLab CI:**
```yaml
security_scan:
  stage: test
  script:
    - make scan
    - make import
  artifacts:
    reports:
      junit: reports/*.json
```

**GitHub Actions:**
```yaml
- name: Security Scan
  run: |
    make scan
    make import
```

**Jenkins:**
```groovy
stage('Security Scan') {
  steps {
    sh 'make scan'
    sh 'make import'
  }
}
```

## Monitoring

### Check import status

```bash
# Via API
curl -X GET http://localhost:8000/api/v2/tests/?engagement=1 \
  -H "Authorization: Token $TOKEN"

# Via UI
# Menu → Engagements → View engagement → Tests tab
```

### View findings

```bash
# Via API
curl -X GET http://localhost:8000/api/v2/findings/?engagement=1 \
  -H "Authorization: Token $TOKEN"

# Via UI
# Menu → Findings → Filter by engagement
```

### Export results

```bash
# Export as CSV
curl -X GET "http://localhost:8000/api/v2/findings/?engagement=1&format=csv" \
  -H "Authorization: Token $TOKEN" > findings.csv

# Export as JSON
curl -X GET "http://localhost:8000/api/v2/findings/?engagement=1" \
  -H "Authorization: Token $TOKEN" | jq > findings.json
```

## Tips & Tricks

1. **Use jq for JSON parsing:**
```bash
# Install jq
brew install jq  # macOS
apt-get install jq  # Linux

# Parse responses
echo "$RESPONSE" | jq '.id'
```

2. **Save API token:**
```bash
# Save to file
echo "$TOKEN" > .defectdojo-token

# Reuse
TOKEN=$(cat .defectdojo-token)
```

3. **Automate with cron:**
```bash
# Daily scan at 2am
0 2 * * * cd /path/to/project && make scan && make import
```

4. **Notifications:**
- Setup Slack webhook in DefectDojo
- Get notified on new findings
- Track SLA breaches

5. **Backup data:**
```bash
# Backup database
docker exec defectdojo-postgres pg_dump -U defectdojo defectdojo > backup.sql

# Backup reports
tar -czf reports-backup.tar.gz reports/
```

## Tài liệu tham khảo

- [DefectDojo API Docs](https://demo.defectdojo.org/api/v2/doc/)
- [Import Scan API](https://documentation.defectdojo.com/integrations/importing/)
- [Supported Formats](https://documentation.defectdojo.com/integrations/parsers/)
