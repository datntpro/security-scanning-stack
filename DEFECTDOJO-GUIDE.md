# Hướng dẫn sử dụng DefectDojo

DefectDojo là nền tảng quản lý lỗ hổng bảo mật (Vulnerability Management) opensource hàng đầu thế giới.

## Tính năng chính

### 1. Centralized Dashboard
- Tổng hợp tất cả findings từ nhiều scanners khác nhau
- Hiển thị metrics, trends, và statistics
- Theo dõi tiến độ remediation

### 2. Deduplication
- Tự động phát hiện và gộp các findings trùng lặp
- Giảm noise và false positives
- Tập trung vào các vấn đề thực sự quan trọng

### 3. Risk Management
- Phân loại theo severity (Critical, High, Medium, Low, Info)
- Assign findings cho team members
- Track remediation status
- Set SLA và deadlines

### 4. Reporting
- Export reports dạng PDF, CSV, JSON
- Compliance reports (OWASP Top 10, PCI-DSS, etc.)
- Executive summaries
- Trend analysis

### 5. Integration
- Hỗ trợ 100+ định dạng scan results
- REST API đầy đủ
- Webhooks và notifications
- CI/CD integration

## Các scanners được hỗ trợ

DefectDojo hỗ trợ import kết quả từ:

### SAST Tools
- ✅ Semgrep JSON Report
- ✅ SonarQube
- ✅ Bandit
- ✅ ESLint
- ✅ PMD

### Secret Detection
- ✅ Gitleaks Scan
- ✅ Trufflehog Scan
- ✅ Detect Secrets

### Container Security
- ✅ Trivy Scan
- ✅ Grype JSON
- ✅ Dockle JSON
- ✅ Clair Scan

### IaC Security
- ✅ Checkov Scan
- ✅ Tfsec Scan
- ✅ KICS Scan
- ✅ Terrascan

### DAST Tools
- ✅ ZAP Scan
- ✅ Nuclei
- ✅ Nikto

### SCA Tools
- ✅ Dependency Check Scan
- ✅ Safety Scan
- ✅ Snyk
- ✅ npm audit
- ✅ pip-audit

## Cách sử dụng

### 1. Khởi động DefectDojo

```bash
# Khởi động DefectDojo và dependencies
make defectdojo-init

# Hoặc
docker compose up -d defectdojo
```

Đợi khoảng 1-2 phút để DefectDojo khởi động hoàn toàn.

### 2. Truy cập Web UI

```
URL: http://localhost:8000
Username: admin
Password: admin
```

**Lưu ý**: Đổi password ngay sau lần đăng nhập đầu tiên!

### 3. Import scan results

#### Cách 1: Tự động (Khuyến nghị)

```bash
# Sau khi chạy scan
make scan

# Import tất cả reports
make import
```

#### Cách 2: Thủ công qua Web UI

1. Đăng nhập vào DefectDojo
2. Tạo Product: `Products` → `Add Product`
   - Name: "My Application"
   - Product Type: "Research and Development"
3. Tạo Engagement: `Engagements` → `Add Engagement`
   - Name: "Security Scan 2024-11-21"
   - Product: Chọn product vừa tạo
   - Target Start/End: Chọn ngày
4. Import Scan: `Findings` → `Import Scan Results`
   - Scan Type: Chọn tool tương ứng (vd: "Semgrep JSON Report")
   - File: Upload file từ thư mục `reports/`
   - Engagement: Chọn engagement vừa tạo

#### Cách 3: Sử dụng API

```bash
# Lấy API token
curl -X POST http://localhost:8000/api/v2/api-token-auth/ \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"admin"}'

# Import scan (thay YOUR_TOKEN)
curl -X POST http://localhost:8000/api/v2/import-scan/ \
  -H "Authorization: Token YOUR_TOKEN" \
  -F "scan_type=Semgrep JSON Report" \
  -F "file=@reports/semgrep-report.json" \
  -F "engagement=1" \
  -F "active=true" \
  -F "verified=true"
```

### 4. Xem và quản lý findings

#### Dashboard
- Truy cập: `Dashboard` → `Product Metrics`
- Xem tổng quan: số lượng findings, severity distribution, trends

#### Findings List
- Truy cập: `Findings` → `All Findings`
- Filter theo: Severity, Status, Scanner, Date
- Bulk actions: Accept risk, Mark false positive, Assign

#### Individual Finding
Click vào một finding để xem:
- **Description**: Mô tả chi tiết lỗ hổng
- **Severity**: Mức độ nghiêm trọng
- **CVSS Score**: Điểm đánh giá
- **CWE/CVE**: Mã định danh
- **Mitigation**: Cách khắc phục
- **References**: Links tham khảo
- **File Path**: Vị trí trong code
- **Line Number**: Dòng code bị lỗi

### 5. Workflow quản lý findings

#### Triage Process
1. **Review**: Xem xét finding có đúng không
2. **Verify**: Xác nhận là lỗ hổng thực sự
3. **Prioritize**: Đánh giá mức độ ưu tiên
4. **Assign**: Giao cho developer
5. **Track**: Theo dõi tiến độ fix
6. **Retest**: Test lại sau khi fix
7. **Close**: Đóng finding

#### Status Workflow
- **Active**: Finding mới, chưa xử lý
- **Verified**: Đã xác nhận là lỗ hổng thực
- **False Positive**: Không phải lỗ hổng
- **Out of Scope**: Ngoài phạm vi
- **Duplicate**: Trùng lặp
- **Risk Accepted**: Chấp nhận rủi ro
- **Mitigated**: Đã khắc phục

### 6. Reporting

#### Generate Report
1. Vào `Reports` → `Generate Report`
2. Chọn:
   - Report Type: Executive, Detailed, Compliance
   - Product/Engagement
   - Date Range
   - Include/Exclude options
3. Click `Generate`
4. Download PDF/CSV

#### Metrics Dashboard
- `Dashboard` → `Metrics`
- Xem:
  - Findings by Severity
  - Findings by Scanner
  - Open vs Closed
  - Time to Remediate
  - Trends over time

### 7. Advanced Features

#### Deduplication
DefectDojo tự động deduplicate findings dựa trên:
- File path + Line number
- CWE/CVE ID
- Hash của finding

Để xem duplicates:
- `Findings` → Filter by `Duplicate`

#### SLA Management
Set SLA cho findings:
1. `Configuration` → `SLA Configuration`
2. Set days to remediate theo severity:
   - Critical: 7 days
   - High: 30 days
   - Medium: 90 days
   - Low: 180 days

#### Notifications
Configure notifications:
1. `Configuration` → `Notifications`
2. Enable:
   - Email notifications
   - Slack integration
   - Webhooks

#### JIRA Integration
Tự động tạo JIRA tickets:
1. `Configuration` → `Tool Configuration`
2. Add JIRA:
   - URL
   - Username/API Token
   - Project Key
3. Enable `Push to JIRA` cho findings

## API Usage

### Authentication
```bash
# Get token
TOKEN=$(curl -s -X POST http://localhost:8000/api/v2/api-token-auth/ \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"admin"}' | \
  jq -r '.token')
```

### List Products
```bash
curl -X GET http://localhost:8000/api/v2/products/ \
  -H "Authorization: Token $TOKEN"
```

### List Engagements
```bash
curl -X GET http://localhost:8000/api/v2/engagements/ \
  -H "Authorization: Token $TOKEN"
```

### List Findings
```bash
# All findings
curl -X GET http://localhost:8000/api/v2/findings/ \
  -H "Authorization: Token $TOKEN"

# Filter by severity
curl -X GET "http://localhost:8000/api/v2/findings/?severity=Critical" \
  -H "Authorization: Token $TOKEN"

# Filter by active status
curl -X GET "http://localhost:8000/api/v2/findings/?active=true" \
  -H "Authorization: Token $TOKEN"
```

### Import Scan
```bash
curl -X POST http://localhost:8000/api/v2/import-scan/ \
  -H "Authorization: Token $TOKEN" \
  -F "scan_type=Semgrep JSON Report" \
  -F "file=@reports/semgrep-report.json" \
  -F "engagement=1" \
  -F "active=true" \
  -F "verified=true" \
  -F "minimum_severity=Info"
```

### Update Finding
```bash
curl -X PATCH http://localhost:8000/api/v2/findings/123/ \
  -H "Authorization: Token $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "active": false,
    "verified": true,
    "false_p": false,
    "duplicate": false,
    "out_of_scope": false,
    "risk_accepted": false,
    "under_review": false,
    "under_defect_review": false
  }'
```

## Best Practices

### 1. Tổ chức Products
- Mỗi application = 1 Product
- Sử dụng Product Types để phân loại
- Set Product Owner và Team

### 2. Tổ chức Engagements
- Mỗi sprint/release = 1 Engagement
- Đặt tên có ngày tháng: "Sprint 24 - 2024-11-21"
- Set target dates rõ ràng

### 3. Scan Frequency
- **Critical apps**: Daily scans
- **Important apps**: Weekly scans
- **Others**: Monthly scans

### 4. Triage Process
- Review findings trong 24h
- Prioritize Critical/High trong 48h
- Assign owners trong 1 tuần

### 5. Metrics Tracking
- Track weekly:
  - New findings
  - Closed findings
  - Average time to remediate
  - Findings by severity
- Set goals và monitor progress

### 6. Integration với CI/CD
```yaml
# Example GitLab CI
security_scan:
  script:
    - make scan
    - make import
  artifacts:
    reports:
      junit: reports/*.json
```

## Troubleshooting

### DefectDojo không khởi động
```bash
# Check logs
docker compose logs defectdojo

# Restart
docker compose restart defectdojo

# Reinitialize
docker compose down -v
make defectdojo-init
```

### Import failed
- Kiểm tra scan type có đúng không
- Kiểm tra file format có hợp lệ không
- Xem logs: `docker compose logs defectdojo-celery-worker`

### Slow performance
```bash
# Increase resources in compose.yaml
defectdojo:
  deploy:
    resources:
      limits:
        cpus: '2'
        memory: 4G
```

### Database issues
```bash
# Backup database
docker exec defectdojo-postgres pg_dump -U defectdojo defectdojo > backup.sql

# Restore
docker exec -i defectdojo-postgres psql -U defectdojo defectdojo < backup.sql
```

## Tài liệu tham khảo

- [DefectDojo Documentation](https://documentation.defectdojo.com/)
- [API Documentation](https://demo.defectdojo.org/api/v2/doc/)
- [GitHub Repository](https://github.com/DefectDojo/django-DefectDojo)
- [Community Slack](https://owasp.slack.com/messages/project-defect-dojo)

## Support

Nếu gặp vấn đề:
1. Check logs: `docker compose logs defectdojo`
2. Check GitHub Issues: https://github.com/DefectDojo/django-DefectDojo/issues
3. Ask on Slack: OWASP DefectDojo channel
