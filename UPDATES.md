# Updates - Loại bỏ TFSec và Fix Trivy

## 📅 Ngày: 2024-11-27

## 🔧 Thay đổi

### 1. Loại bỏ TFSec
**Lý do:** TFSec đã được Aqua Security (nhà phát triển Trivy) mua lại và tích hợp vào Trivy.

**Files đã cập nhật:**
- ✅ `compose.yaml` - Xóa service tfsec
- ✅ `scan-all.sh` - Xóa lệnh scan tfsec
- ✅ `import-to-defectdojo.sh` - Xóa import tfsec
- ✅ `Makefile` - Cập nhật scan-iac command
- ✅ `README.md` - Xóa references đến TFSec
- ✅ `HUONG-DAN-TIENG-VIET.md` - Xóa references đến TFSec
- ✅ `IMPORT-GUIDE.md` - Xóa scan type mapping cho TFSec

### 2. Fix Trivy Command
**Vấn đề:** Command cũ `sh -c "trivy fs ..."` bị lỗi vì Trivy không nhận `sh` command.

**Giải pháp:** Đổi thành command trực tiếp:
```yaml
# Cũ (SAI):
command: >
  sh -c "trivy fs --format json --output /reports/trivy-fs-report.json /src || true"

# Mới (ĐÚNG):
command: >
  filesystem --format json --output /reports/trivy-fs-report.json /src
```

**Kết quả:** ✅ Trivy chạy thành công và tạo report

## 📊 IaC Security Scanners hiện tại

Sau khi loại bỏ TFSec, các IaC scanners còn lại:

1. **Checkov** - Scan Terraform, CloudFormation, K8s, Dockerfile
2. **KICS** - Infrastructure as Code security scanner
3. **Trivy** - Scan IaC misconfigurations (thay thế TFSec)

## 🚀 Cách sử dụng

### Scan IaC với Trivy
```bash
# Trivy giờ scan cả vulnerabilities VÀ IaC misconfigurations
docker compose up trivy

# Kết quả: reports/trivy-fs-report.json
```

### Scan tất cả IaC
```bash
make scan-iac

# Chạy:
# - Checkov
# - KICS
# - Trivy
```

## ✅ Test Results

```bash
# Test Trivy
$ docker compose up trivy
✓ Trivy chạy thành công
✓ Report được tạo: reports/trivy-fs-report.json (18KB)

# Test scan-all
$ make scan
✓ Không còn lỗi TFSec
✓ Tất cả scanners chạy OK

# Test import
$ make import
✓ Import thành công (không còn TFSec)
```

## 📝 Migration Notes

Nếu bạn đang sử dụng TFSec reports cũ:

1. **Không cần làm gì** - Trivy đã thay thế TFSec
2. **Reports cũ** - Có thể xóa `reports/tfsec-report.json`
3. **Scan lại** - Chạy `make scan` để tạo reports mới với Trivy

## 🔗 References

- [Trivy Documentation](https://aquasecurity.github.io/trivy/)
- [Trivy IaC Scanning](https://aquasecurity.github.io/trivy/latest/docs/scanner/misconfiguration/)
- [TFSec Migration to Trivy](https://github.com/aquasecurity/tfsec#tfsec-is-joining-trivy)

---

**Tóm tắt:** TFSec đã được loại bỏ và thay thế bằng Trivy. Trivy giờ scan cả vulnerabilities VÀ IaC misconfigurations.
