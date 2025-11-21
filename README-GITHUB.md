# Security Scanning Stack

🔒 Hệ thống quét bảo mật source code tự động với Docker Compose

## Tính năng

- ✅ **SAST**: Semgrep, SonarQube
- ✅ **Secret Detection**: Gitleaks, TruffleHog  
- ✅ **Container Security**: Trivy, Grype, Dockle
- ✅ **IaC Security**: Checkov, TFSec, KICS
- ✅ **SCA**: OWASP Dependency-Check, Safety
- ✅ **DAST**: OWASP ZAP, Nuclei
- ✅ **Vulnerability Management**: DefectDojo

## Quick Start

```bash
# 1. Setup
make setup
cp -r /path/to/your/code source/

# 2. Scan
make scan

# 3. Import vào DefectDojo
make import

# 4. Xem báo cáo tiếng Việt
make report-vi
```

## Kết quả

- **593 lỗ hổng** được phát hiện trong WebGoat project
- **178 HIGH severity** findings
- Báo cáo HTML chi tiết bằng tiếng Việt
- Hướng dẫn fix cụ thể cho từng lỗ hổng

## Tài liệu

- [Hướng dẫn tiếng Việt](HUONG-DAN-TIENG-VIET.md)
- [English README](README.md)
- [DefectDojo Guide](DEFECTDOJO-GUIDE.md)
- [Architecture](ARCHITECTURE.md)

## Requirements

- Docker & Docker Compose
- 8GB RAM minimum
- 20GB disk space

## License

Private - Internal Use Only
