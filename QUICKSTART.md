# Quick Start Guide

Hướng dẫn nhanh để bắt đầu scan source code và quản lý vulnerabilities.

## 🚀 Bắt đầu trong 5 phút

### Bước 1: Chuẩn bị source code

```bash
# Tạo thư mục
make setup

# Copy source code cần scan
cp -r /path/to/your/project/* source/

# Hoặc clone từ git
git clone https://github.com/your/repo source/your-project
```

### Bước 2: Khởi động services

```bash
# Khởi động tất cả
make up

# Đợi 1-2 phút để services khởi động
```

### Bước 3: Chạy scan

```bash
# Chạy tất cả scanners
bash scan-all.sh

# Script sẽ hỏi có muốn import vào DefectDojo không
# Chọn 'y' để tự động import
```

### Bước 4: Xem kết quả

#### Option 1: DefectDojo (Khuyến nghị)
```
URL: http://localhost:8000
Username: admin
Password: admin
```

Tại đây bạn sẽ thấy:
- ✅ Tổng hợp tất cả findings từ mọi scanners
- ✅ Dashboard với metrics và trends
- ✅ Findings được deduplicate và prioritize
- ✅ Export reports PDF/CSV

#### Option 2: Xem raw reports
```bash
# Liệt kê reports
make reports

# Xem report cụ thể
cat reports/gitleaks-report.json | jq
cat reports/semgrep-report.json | jq
```

#### Option 3: SonarQube
```
URL: http://localhost:9000
Username: admin
Password: admin
```

## 📊 Workflow hoàn chỉnh

```
┌─────────────────┐
│  Source Code    │
│   in source/    │
└────────┬────────┘
         │
         ▼
┌─────────────────────────────────────────┐
│         Run Security Scanners           │
│  • Gitleaks (Secrets)                   │
│  • Semgrep (SAST)                       │
│  • Trivy (Containers)                   │
│  • Checkov (IaC)                        │
│  • Dependency-Check (SCA)               │
│  • ... và nhiều hơn                     │
└────────┬────────────────────────────────┘
         │
         ▼
┌─────────────────┐
│  Raw Reports    │
│  in reports/    │
└────────┬────────┘
         │
         ▼
┌─────────────────────────────────────────┐
│         Import to DefectDojo            │
│  • Deduplicate findings                 │
│  • Normalize severity                   │
│  • Enrich with metadata                 │
└────────┬────────────────────────────────┘
         │
         ▼
┌─────────────────────────────────────────┐
│      Vulnerability Management           │
│  • Review & Triage                      │
│  • Assign to developers                 │
│  • Track remediation                    │
│  • Generate reports                     │
└─────────────────────────────────────────┘
```

## 🎯 Use Cases phổ biến

### Use Case 1: Scan một lần (Ad-hoc)
```bash
make setup
cp -r ~/my-project source/
make scan
make import
# Xem kết quả tại http://localhost:8000
```

### Use Case 2: Scan định kỳ (Weekly)
```bash
# Tạo cron job
crontab -e

# Thêm dòng này (chạy mỗi thứ 2 lúc 9am)
0 9 * * 1 cd /path/to/scan && make scan && make import
```

### Use Case 3: CI/CD Integration
```yaml
# .gitlab-ci.yml
security_scan:
  stage: test
  script:
    - docker compose up -d
    - make scan
    - make import
  artifacts:
    paths:
      - reports/
```

### Use Case 4: Scan nhiều projects
```bash
# Project 1
cp -r ~/project1 source/project1
make scan
make import

# Project 2
rm -rf source/*
cp -r ~/project2 source/project2
make scan
make import

# Tất cả sẽ được tổng hợp trong DefectDojo
```

### Use Case 5: Chỉ scan một loại cụ thể
```bash
# Chỉ scan secrets
make scan-secrets

# Chỉ scan IaC
make scan-iac

# Chỉ scan containers
make scan-container
```

## 🔧 Customization

### Thay đổi scanners chạy

Edit `scan-all.sh` và comment out scanners không cần:

```bash
# echo -e "${YELLOW}→ Running Grype...${NC}"
# docker compose up grype
```

### Thêm custom rules cho Semgrep

```bash
# Tạo file rules
mkdir -p source/.semgrep
cat > source/.semgrep/custom-rules.yaml << EOF
rules:
  - id: hardcoded-password
    pattern: password = "..."
    message: Hardcoded password detected
    severity: ERROR
    languages: [python, javascript]
EOF

# Chạy với custom rules
docker compose run semgrep semgrep --config=/src/.semgrep /src
```

### Thêm custom config cho Gitleaks

```bash
# Tạo file config
cat > source/.gitleaks.toml << EOF
[allowlist]
paths = [
  '''node_modules/''',
  '''vendor/'''
]
EOF

# Gitleaks sẽ tự động sử dụng config này
```

## 📈 Monitoring & Metrics

### Xem số lượng findings
```bash
# Trong DefectDojo
curl -s -X GET http://localhost:8000/api/v2/findings/ \
  -H "Authorization: Token YOUR_TOKEN" | \
  jq '.count'
```

### Track trends
1. Vào DefectDojo: `Dashboard` → `Metrics`
2. Xem:
   - Findings over time
   - Severity distribution
   - Time to remediate
   - Scanner coverage

### Export metrics
```bash
# Export findings as CSV
curl -X GET "http://localhost:8000/api/v2/findings/?format=csv" \
  -H "Authorization: Token YOUR_TOKEN" > findings.csv
```

## 🛠️ Troubleshooting

### Services không khởi động
```bash
# Check logs
docker compose logs

# Restart specific service
docker compose restart defectdojo

# Full restart
docker compose down
docker compose up -d
```

### Scan failed
```bash
# Check scanner logs
docker compose logs semgrep
docker compose logs trivy

# Retry specific scanner
docker compose up semgrep
```

### Import failed
```bash
# Check import script logs
bash import-to-defectdojo.sh

# Manual import via UI
# 1. Go to http://localhost:8000
# 2. Findings → Import Scan Results
# 3. Upload file từ reports/
```

### Out of disk space
```bash
# Clean up
make clean-all

# Remove old images
docker system prune -a
```

## 📚 Next Steps

1. **Đọc hướng dẫn chi tiết**: [README.md](README.md)
2. **Tìm hiểu DefectDojo**: [DEFECTDOJO-GUIDE.md](DEFECTDOJO-GUIDE.md)
3. **Customize scanners**: Edit `compose.yaml`
4. **Setup CI/CD**: Integrate vào pipeline
5. **Configure notifications**: Setup Slack/Email alerts

## 💡 Tips & Best Practices

1. **Scan thường xuyên**: Càng sớm phát hiện càng dễ fix
2. **Review findings ngay**: Đừng để tích lũy
3. **Prioritize Critical/High**: Focus vào rủi ro cao trước
4. **Track metrics**: Monitor progress theo thời gian
5. **Automate**: Tích hợp vào CI/CD pipeline
6. **Educate team**: Training về secure coding
7. **Update scanners**: Keep tools up-to-date
8. **Backup data**: Backup DefectDojo database định kỳ

## 🆘 Need Help?

- Check [README.md](README.md) cho hướng dẫn chi tiết
- Check [DEFECTDOJO-GUIDE.md](DEFECTDOJO-GUIDE.md) cho DefectDojo
- Check logs: `docker compose logs`
- Check GitHub issues của từng tool
- Ask on OWASP Slack

## 🎉 Enjoy Scanning!

Happy hunting! 🔍🐛
