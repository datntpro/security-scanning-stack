# Quick Start - Hướng dẫn nhanh 5 phút

## Bước 1: Khởi động DefectDojo (1 phút)

```bash
make defectdojo-init
```

Đợi 30-60 giây để DefectDojo khởi động.

## Bước 2: Chuẩn bị source code (30 giây)

```bash
# Sử dụng files mẫu có sẵn (đã có 50+ lỗ hổng)
ls -la source/

# Hoặc copy code của bạn
cp -r /path/to/your/code source/
```

## Bước 3: Chạy scan (2 phút)

```bash
make scan
```

## Bước 4: Import vào DefectDojo (30 giây)

```bash
make import
```

## Bước 5: Xem kết quả (30 giây)

```bash
# Mở DefectDojo UI
make open-defectdojo

# Hoặc tạo báo cáo tiếng Việt
make report-vi
```

## ✅ Hoàn tất!

Truy cập http://localhost:8000 để xem findings.

---

## Các lệnh hữu ích

```bash
# Xem trạng thái services
docker compose ps

# Xem logs
docker compose logs defectdojo

# Restart DefectDojo
docker compose restart defectdojo defectdojo-nginx

# Dừng tất cả
make down

# Xóa reports và restart
make clean
make scan
make import
```

## Troubleshooting nhanh

**DefectDojo không truy cập được:**
```bash
docker compose up -d defectdojo-nginx
sleep 10
curl http://localhost:8000/login
```

**Import failed:**
```bash
docker compose restart defectdojo defectdojo-nginx
sleep 10
make import
```

**Scan không có kết quả:**
```bash
# Kiểm tra source code có files không
ls -la source/

# Xem logs của scanner
docker compose logs semgrep
docker compose logs gitleaks
```

---

Xem hướng dẫn chi tiết: [HUONG-DAN-TIENG-VIET.md](HUONG-DAN-TIENG-VIET.md)
