# 📚 Documentation Index

Chào mừng đến với Security Scanning Stack! Chọn hướng dẫn phù hợp với bạn:

## 🎯 Bạn muốn làm gì?

### ⚡ Tôi muốn bắt đầu ngay (5 phút)
→ **[QUICKSTART.md](QUICKSTART.md)**

### 📖 Tôi muốn hiểu chi tiết từng bước
→ **[HUONG-DAN-TIENG-VIET.md](HUONG-DAN-TIENG-VIET.md)** (Tiếng Việt)
→ **[README.md](README.md)** (English)

### 🔧 Tôi gặp vấn đề với import
→ **[IMPORT-GUIDE.md](IMPORT-GUIDE.md)**

### 📊 Tôi muốn xem tổng quan
→ **[SUMMARY.md](SUMMARY.md)**

### 📝 Tôi muốn xem lịch sử thay đổi
→ **[CHANGELOG.md](CHANGELOG.md)**

---

## 📁 Cấu trúc Documentation

```
📚 Documentation
├── 🚀 QUICKSTART.md              # Bắt đầu nhanh (5 phút)
├── 📖 README.md                  # Hướng dẫn tổng quan (English)
├── 🇻🇳 HUONG-DAN-TIENG-VIET.md   # Hướng dẫn chi tiết (Tiếng Việt)
├── 📥 IMPORT-GUIDE.md            # Hướng dẫn import chi tiết
├── 📊 SUMMARY.md                 # Tóm tắt và best practices
├── 📝 CHANGELOG.md               # Lịch sử thay đổi
└── 📚 INDEX.md                   # File này
```

---

## 🎓 Learning Path

### Người mới bắt đầu
1. [QUICKSTART.md](QUICKSTART.md) - Chạy scan đầu tiên
2. [HUONG-DAN-TIENG-VIET.md](HUONG-DAN-TIENG-VIET.md) - Hiểu chi tiết
3. [SUMMARY.md](SUMMARY.md) - Best practices

### Người đã có kinh nghiệm
1. [README.md](README.md) - Quick reference
2. [IMPORT-GUIDE.md](IMPORT-GUIDE.md) - Advanced import
3. [SUMMARY.md](SUMMARY.md) - Optimization tips

### DevOps/CI/CD Engineer
1. [IMPORT-GUIDE.md](IMPORT-GUIDE.md) - API usage
2. [README.md](README.md) - Integration examples
3. [SUMMARY.md](SUMMARY.md) - Automation

---

## 🚀 Quick Commands

```bash
# Bắt đầu
make defectdojo-init    # Khởi động DefectDojo
make scan               # Chạy scan
make import             # Import kết quả
make open-defectdojo    # Xem findings

# Xem thêm
make help               # Xem tất cả commands
```

---

## 🆘 Troubleshooting

**DefectDojo không truy cập được?**
```bash
docker compose up -d defectdojo-nginx
```

**Import failed?**
```bash
docker compose restart defectdojo defectdojo-nginx
sleep 10
make import
```

**Cần help?**
- Xem [IMPORT-GUIDE.md](IMPORT-GUIDE.md) - Troubleshooting section
- Xem [HUONG-DAN-TIENG-VIET.md](HUONG-DAN-TIENG-VIET.md) - Phần Troubleshooting

---

**Bắt đầu ngay:** [QUICKSTART.md](QUICKSTART.md) ⚡
