# Changelog hehe

## 2024-11-26 - Loại bỏ OWASP ZAP

### Đã xóa
- ❌ OWASP ZAP - Tool DAST yêu cầu test manual, không phù hợp với automated scanning
- ❌ Xóa service owasp-zap khỏi compose.yaml
- ❌ Xóa tất cả tham chiếu đến ZAP trong documentation
- ❌ Xóa import ZAP report trong import-to-defectdojo.sh
- ❌ Xóa khởi động ZAP trong scan-all.sh

### Lý do
- OWASP ZAP yêu cầu cấu hình manual và target URL cụ thể
- Không phù hợp với automated source code scanning
- Nuclei vẫn được giữ lại cho DAST scanning

## 2024-11-22 - Dọn dẹp và tối ưu hóa

### Đã xóa
- ❌ QUICKSTART.md (gộp vào README.md)
- ❌ ARCHITECTURE.md (quá chi tiết, không cần thiết)
- ❌ DEFECTDOJO-GUIDE.md (gộp vào HUONG-DAN-TIENG-VIET.md)
- ❌ DEFECTDOJO-UI-GUIDE.md (gộp vào HUONG-DAN-TIENG-VIET.md)
- ❌ IMPORT-GUIDE.md (gộp vào HUONG-DAN-TIENG-VIET.md)
- ❌ TROUBLESHOOTING.md (gộp vào HUONG-DAN-TIENG-VIET.md)
- ❌ DEMO.md (không cần thiết)
- ❌ SCAN-RESULTS.md (không cần thiết)
- ❌ PUSH-TO-GITHUB.md (không cần thiết)
- ❌ README-GITHUB.md (trùng lặp)
- ❌ Scripts không cần: generate-report.sh, show-findings.sh, test-defectdojo.sh, open-defectdojo.sh, push-to-github.sh, setup-github-manual.sh
- ❌ HTML reports cũ: security-report.html, bao-cao-bao-mat.html

### Giữ lại
- ✅ README.md - Hướng dẫn chính (tiếng Anh)
- ✅ HUONG-DAN-TIENG-VIET.md - Hướng dẫn đầy đủ (tiếng Việt)
- ✅ compose.yaml - Docker Compose configuration
- ✅ Makefile - Commands tiện lợi
- ✅ scan-all.sh - Script scan tự động
- ✅ import-to-defectdojo.sh - Script import findings
- ✅ generate-vietnamese-report.sh - Tạo báo cáo tiếng Việt
- ✅ nginx.conf - Nginx configuration cho DefectDojo

### Cải tiến
- ✨ Gộp tất cả hướng dẫn vào 2 file chính
- ✨ Cập nhật Makefile để loại bỏ dependencies không cần thiết
- ✨ Thêm .gitkeep cho thư mục source/ và reports/
- ✨ Cập nhật .gitignore để giữ .gitkeep files

### Cấu trúc mới
```
.
├── compose.yaml                    # Docker Compose
├── Makefile                        # Commands
├── README.md                       # Hướng dẫn tiếng Anh
├── HUONG-DAN-TIENG-VIET.md        # Hướng dẫn tiếng Việt (đầy đủ)
├── scan-all.sh                     # Script scan
├── import-to-defectdojo.sh        # Script import
├── generate-vietnamese-report.sh   # Script báo cáo
├── nginx.conf                      # Nginx config
├── source/                         # Source code cần scan
└── reports/                        # Kết quả scan
```
