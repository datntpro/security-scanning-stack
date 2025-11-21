# DefectDojo UI Guide - Hướng dẫn sử dụng giao diện

## Truy cập DefectDojo

```bash
# Mở trong browser
make open-defectdojo

# Hoặc truy cập: http://localhost:8000
```

**Thông tin đăng nhập:**
- Username: `admin`
- Password: `admin`

## Giao diện chính

### 1. Dashboard (Trang chủ)

Sau khi đăng nhập, bạn sẽ thấy Dashboard với:

**Metrics Overview:**
- Total Findings: Tổng số lỗ hổng
- Critical/High/Medium/Low: Phân loại theo mức độ nghiêm trọng
- Open vs Closed: Findings đang mở vs đã đóng
- Accepted Risks: Rủi ro đã chấp nhận

**Charts:**
- Findings by Severity (Pie chart)
- Findings by Product (Bar chart)
- Findings Trend (Line chart)
- Top 10 Products by Findings

**Quick Actions:**
- Add Product
- Add Engagement
- Import Scan
- View All Findings

### 2. Products (Sản phẩm)

**Truy cập:** Menu → Products

**Chức năng:**
- Xem danh sách tất cả products
- Tạo product mới
- Xem metrics của từng product
- Quản lý engagements

**Tạo Product mới:**
1. Click "Add Product"
2. Điền thông tin:
   - Name: Tên ứng dụng (vd: "My Web App")
   - Description: Mô tả
   - Product Type: Chọn loại (vd: "Web Application")
   - Business Criticality: Mức độ quan trọng
3. Click "Submit"

### 3. Engagements (Đợt scan)

**Truy cập:** Menu → Engagements

**Engagement là gì?**
- Một đợt scan/test cụ thể
- Thuộc về một Product
- Có thời gian bắt đầu và kết thúc
- Chứa các Test (scan results)

**Tạo Engagement mới:**
1. Vào Product → Click "Add Engagement"
2. Điền thông tin:
   - Name: "Security Scan 2024-11-21"
   - Target Start/End: Ngày bắt đầu/kết thúc
   - Engagement Type: "CI/CD"
   - Status: "In Progress"
3. Click "Done"

### 4. Import Scan Results

**Cách 1: Tự động (Khuyến nghị)**
```bash
make import
```

**Cách 2: Thủ công qua UI**

1. Vào Engagement → Click "Import Scan Results"
2. Chọn thông tin:
   - **Scan Type**: Chọn tool tương ứng
     - Gitleaks → "Gitleaks Scan"
     - Semgrep → "Semgrep JSON Report"
     - Trivy → "Trivy Scan"
     - Checkov → "Checkov Scan"
     - TFSec → "Tfsec Scan"
     - KICS → "KICS Scan"
     - Grype → "Grype JSON"
     - Dependency-Check → "Dependency Check Scan"
     - Safety → "Safety Scan"
     - OWASP ZAP → "ZAP Scan"
   - **File**: Upload file từ `reports/`
   - **Engagement**: Chọn engagement
   - **Active**: ✅ (findings đang active)
   - **Verified**: ✅ (findings đã verify)
3. Click "Import"

**Lưu ý:** Import có thể mất vài giây đến vài phút tùy kích thước file.

### 5. Findings (Lỗ hổng)

**Truy cập:** Menu → Findings → All Findings

**Giao diện Findings List:**
- **Filters** (bên trái):
  - Severity: Critical, High, Medium, Low, Info
  - Status: Active, Verified, False Positive, etc.
  - Product/Engagement
  - Date Range
  - Scanner Type
  
- **Findings Table:**
  - Title: Tên lỗ hổng
  - Severity: Mức độ nghiêm trọng (màu sắc)
  - Status: Trạng thái
  - Date: Ngày phát hiện
  - Product: Thuộc product nào
  - Actions: View, Edit, Delete

**Xem chi tiết Finding:**

Click vào một finding để xem:

1. **Overview Tab:**
   - Title & Description
   - Severity & CVSS Score
   - CWE/CVE ID
   - Status & Date
   - File Path & Line Number
   - Mitigation (cách khắc phục)

2. **Notes Tab:**
   - Thêm ghi chú
   - Comment discussion
   - History của finding

3. **References Tab:**
   - Links tham khảo
   - Documentation
   - CVE details

4. **Actions:**
   - Edit: Sửa thông tin
   - Mark as False Positive: Đánh dấu là false positive
   - Accept Risk: Chấp nhận rủi ro
   - Close: Đóng finding
   - Assign: Giao cho developer
   - Add to JIRA: Tạo JIRA ticket

### 6. Metrics & Reports

**Truy cập:** Menu → Metrics

**Product Metrics:**
- Findings by Severity
- Findings by Age
- Findings by Scanner
- Open vs Closed Trends
- Time to Remediate

**Engagement Metrics:**
- Test Coverage
- Findings Distribution
- Progress Tracking

**Generate Report:**
1. Menu → Reports → Generate Report
2. Chọn:
   - Report Type: Executive, Detailed, Compliance
   - Product/Engagement
   - Date Range
   - Include/Exclude options
3. Click "Generate"
4. Download PDF/CSV

### 7. Workflow quản lý Finding

**Bước 1: Triage (Phân loại)**
1. Vào Findings → All Findings
2. Filter: Status = "Active"
3. Review từng finding:
   - Đọc description
   - Xem file path & line number
   - Check severity

**Bước 2: Verify (Xác nhận)**
1. Click vào finding
2. Verify có phải lỗ hổng thực không
3. Nếu đúng: Mark as "Verified"
4. Nếu sai: Mark as "False Positive"

**Bước 3: Prioritize (Ưu tiên)**
1. Sort by Severity
2. Focus vào Critical & High trước
3. Check Business Criticality

**Bước 4: Assign (Giao việc)**
1. Click "Edit"
2. Assign to: Chọn developer
3. Set Due Date
4. Add Note với context

**Bước 5: Track (Theo dõi)**
1. Developer fix code
2. Update status: "Under Review"
3. Retest sau khi fix
4. Close nếu đã fix xong

**Bước 6: Report (Báo cáo)**
1. Generate weekly/monthly report
2. Share với management
3. Track metrics & trends

### 8. Deduplication

DefectDojo tự động deduplicate findings dựa trên:
- File path + Line number
- CWE/CVE ID
- Hash của finding

**Xem duplicates:**
1. Findings → Filter by "Duplicate"
2. Click vào finding
3. Xem "Original Finding" link

**Merge duplicates:**
1. Vào finding
2. Click "Mark as Duplicate"
3. Chọn original finding

### 9. Bulk Actions

**Chọn nhiều findings:**
1. Tick checkbox bên trái findings
2. Click "Bulk Edit" ở trên
3. Chọn action:
   - Change Status
   - Assign to User
   - Accept Risk
   - Mark False Positive
   - Delete

### 10. Search & Filter

**Quick Search:**
- Search box ở góc phải trên
- Tìm theo: Title, Description, CVE, CWE

**Advanced Filter:**
1. Click "Advanced Filter"
2. Chọn nhiều criteria:
   - Severity
   - Status
   - Product
   - Date Range
   - Scanner
   - Tags
3. Click "Apply"

**Save Filter:**
1. Set up filter
2. Click "Save Filter"
3. Đặt tên
4. Reuse sau này

### 11. Notifications

**Setup Email Notifications:**
1. Menu → Configuration → Notifications
2. Enable:
   - New Finding
   - SLA Breach
   - Status Change
3. Set recipients

**Setup Slack:**
1. Configuration → Tool Configuration
2. Add Slack Webhook URL
3. Choose events to notify

### 12. User Management

**Add User:**
1. Menu → Configuration → Users
2. Click "Add User"
3. Điền thông tin:
   - Username
   - Email
   - Role: Reader, Writer, Maintainer, Owner
4. Click "Submit"

**Roles:**
- **Reader**: Chỉ xem
- **Writer**: Xem và edit findings
- **Maintainer**: Quản lý product
- **Owner**: Full access
- **Superuser**: Admin toàn hệ thống

### 13. Tips & Tricks

**Keyboard Shortcuts:**
- `/` : Focus search box
- `g` + `d` : Go to Dashboard
- `g` + `f` : Go to Findings
- `g` + `p` : Go to Products

**Quick Filters:**
- Click vào severity badge để filter
- Click vào product name để xem findings của product đó
- Click vào date để filter by date range

**Bookmarks:**
- Bookmark các filter thường dùng
- Bookmark specific findings
- Bookmark reports

**Export Data:**
- Findings → Export → CSV/JSON
- Use for external analysis
- Import vào Excel/Google Sheets

### 14. Mobile Access

DefectDojo responsive, có thể dùng trên mobile:
- View findings
- Update status
- Add notes
- Approve risks

### 15. API Access

**Get API Token:**
1. Menu → API Key
2. Click "Generate"
3. Copy token

**Use API:**
```bash
# Get findings
curl -X GET http://localhost:8000/api/v2/findings/ \
  -H "Authorization: Token YOUR_TOKEN"

# Import scan
curl -X POST http://localhost:8000/api/v2/import-scan/ \
  -H "Authorization: Token YOUR_TOKEN" \
  -F "scan_type=Semgrep JSON Report" \
  -F "file=@reports/semgrep-report.json" \
  -F "engagement=1"
```

## Troubleshooting UI

### CSS không load
- Clear browser cache
- Hard refresh: Cmd+Shift+R (Mac) hoặc Ctrl+Shift+R (Windows)
- Check nginx logs: `docker compose logs defectdojo-nginx`

### Trang load chậm
- Check resources: `docker stats`
- Scale celery workers: `docker compose up -d --scale defectdojo-celery-worker=3`

### Không login được
- Reset password: `make defectdojo-init`
- Check logs: `docker compose logs defectdojo`

### Import failed
- Check file format
- Check scan type mapping
- View celery logs: `docker compose logs defectdojo-celery-worker`

## Best Practices

1. **Tổ chức Products:**
   - Một app = một product
   - Đặt tên rõ ràng
   - Set business criticality đúng

2. **Tổ chức Engagements:**
   - Một sprint/release = một engagement
   - Đặt tên có ngày: "Sprint 24 - 2024-11-21"
   - Set target dates

3. **Triage Findings:**
   - Review trong 24h
   - Prioritize Critical/High
   - Assign owners

4. **Track Progress:**
   - Weekly metrics review
   - Monthly reports
   - Trend analysis

5. **Collaborate:**
   - Add notes với context
   - Tag relevant people
   - Use JIRA integration

## Tài liệu tham khảo

- [DefectDojo Documentation](https://documentation.defectdojo.com/)
- [User Guide](https://documentation.defectdojo.com/usage/)
- [API Documentation](https://demo.defectdojo.org/api/v2/doc/)
