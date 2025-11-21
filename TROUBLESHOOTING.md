# Troubleshooting Guide

## DefectDojo Issues

### Issue: DefectDojo không khởi động

**Triệu chứng:**
```
Container defectdojo is unhealthy
```

**Nguyên nhân:**
- Health check fail
- Database chưa sẵn sàng
- Port conflict

**Giải pháp:**

1. Kiểm tra logs:
```bash
docker compose logs defectdojo
```

2. Kiểm tra database:
```bash
docker compose logs postgres
docker exec defectdojo-postgres pg_isready -U defectdojo
```

3. Restart services:
```bash
docker compose restart defectdojo
```

4. Full reset:
```bash
docker compose down
docker compose up -d
```

### Issue: Không login được vào DefectDojo

**Triệu chứng:**
```
Unable to log in with provided credentials
```

**Giải pháp:**

Reset password cho admin user:
```bash
docker exec defectdojo python manage.py shell -c "
from django.contrib.auth.models import User
user = User.objects.get(username='admin')
user.set_password('admin')
user.save()
print('Password reset successfully')
"
```

### Issue: Port 8000 đã được sử dụng

**Triệu chứng:**
```
Error: bind: address already in use
```

**Giải pháp:**

1. Tìm process đang dùng port:
```bash
lsof -i :8000
# hoặc
netstat -tulpn | grep 8000
```

2. Thay đổi port trong compose.yaml:
```yaml
defectdojo:
  ports:
    - "8001:8081"  # Đổi từ 8000 sang 8001
```

### Issue: Import scan failed

**Triệu chứng:**
```
Import failed (HTTP 400/500)
```

**Giải pháp:**

1. Kiểm tra file format:
```bash
cat reports/semgrep-report.json | jq
```

2. Kiểm tra scan type mapping:
- Gitleaks → "Gitleaks Scan"
- Semgrep → "Semgrep JSON Report"
- Trivy → "Trivy Scan"
- Checkov → "Checkov Scan"

3. Xem Celery worker logs:
```bash
docker compose logs defectdojo-celery-worker
```

4. Manual import qua UI:
- Vào http://localhost:8000
- Findings → Import Scan Results
- Chọn scan type và upload file

## Scanner Issues

### Issue: Semgrep không tìm thấy issues

**Giải pháp:**

Chạy với ruleset cụ thể:
```bash
docker compose run semgrep semgrep --config=p/security-audit /src
docker compose run semgrep semgrep --config=p/owasp-top-ten /src
```

### Issue: Gitleaks báo quá nhiều false positives

**Giải pháp:**

Tạo file `.gitleaks.toml` trong thư mục source:
```toml
[allowlist]
paths = [
  '''node_modules/''',
  '''vendor/''',
  '''\.git/'''
]

regexes = [
  '''test.*password''',
  '''example.*key'''
]
```

### Issue: Trivy scan chậm

**Giải pháp:**

1. Sử dụng cache:
```bash
# Cache đã được mount sẵn trong compose.yaml
docker compose up trivy
```

2. Scan chỉ vulnerabilities:
```bash
docker compose run trivy trivy fs --scanners vuln /src
```

### Issue: Dependency-Check tải database lâu

**Giải pháp:**

Database được cache trong volume. Lần đầu sẽ lâu (5-10 phút), lần sau nhanh hơn.

Để update database:
```bash
docker compose run dependency-check \
  /usr/share/dependency-check/bin/dependency-check.sh --updateonly
```

## Performance Issues

### Issue: Scan quá chậm

**Giải pháp:**

1. Chạy từng scanner thay vì tất cả:
```bash
make scan-secrets  # Nhanh nhất
make scan-sast     # Trung bình
make scan-sca      # Chậm nhất
```

2. Exclude thư mục không cần:
```bash
# Thêm vào .gitignore hoặc exclude pattern
node_modules/
vendor/
.git/
```

3. Tăng resources cho Docker:
- Docker Desktop → Settings → Resources
- Tăng CPU: 4+ cores
- Tăng Memory: 8+ GB

### Issue: DefectDojo chậm

**Giải pháp:**

1. Scale Celery workers:
```bash
docker compose up -d --scale defectdojo-celery-worker=3
```

2. Tăng resources trong compose.yaml:
```yaml
defectdojo:
  deploy:
    resources:
      limits:
        cpus: '2'
        memory: 4G
```

## Network Issues

### Issue: Không kết nối được giữa các containers

**Giải pháp:**

1. Kiểm tra network:
```bash
docker network ls
docker network inspect security-scan_security-scan
```

2. Restart network:
```bash
docker compose down
docker compose up -d
```

### Issue: Cannot resolve hostname

**Giải pháp:**

Sử dụng container name thay vì localhost:
- ✅ `http://defectdojo:8081`
- ❌ `http://localhost:8000`

## Storage Issues

### Issue: Disk full

**Giải pháp:**

1. Clean up reports:
```bash
make clean
```

2. Clean up Docker:
```bash
docker system prune -a
docker volume prune
```

3. Remove old images:
```bash
docker images | grep '<none>' | awk '{print $3}' | xargs docker rmi
```

### Issue: Volume permission denied

**Giải pháp:**

Fix permissions:
```bash
chmod -R 755 source/
chmod -R 777 reports/
```

## Database Issues

### Issue: PostgreSQL không khởi động

**Giải pháp:**

1. Check logs:
```bash
docker compose logs postgres
```

2. Reset database:
```bash
docker compose down -v
docker compose up -d postgres
```

3. Backup trước khi reset:
```bash
docker exec defectdojo-postgres pg_dump -U defectdojo defectdojo > backup.sql
```

### Issue: Database migration failed

**Giải pháp:**

Run migrations manually:
```bash
docker exec defectdojo python manage.py migrate
```

## Common Errors

### Error: "version is obsolete"

**Giải pháp:**

Đã fix trong compose.yaml mới. Nếu vẫn thấy, xóa dòng `version: '3.8'`.

### Error: "no such service"

**Giải pháp:**

Check service name trong compose.yaml:
```bash
docker compose config --services
```

### Error: "pull access denied"

**Giải pháp:**

1. Check internet connection
2. Retry pull:
```bash
docker compose pull
```

3. Use alternative registry nếu cần

## Getting Help

### Collect diagnostic info

```bash
# System info
docker version
docker compose version

# Services status
docker compose ps

# Logs
docker compose logs > all-logs.txt

# Resource usage
docker stats --no-stream
```

### Check documentation

- [README.md](README.md) - General usage
- [DEFECTDOJO-GUIDE.md](DEFECTDOJO-GUIDE.md) - DefectDojo specific
- [QUICKSTART.md](QUICKSTART.md) - Quick start guide
- [ARCHITECTURE.md](ARCHITECTURE.md) - System architecture

### Test DefectDojo

```bash
make test-defectdojo
```

### Community support

- DefectDojo: https://github.com/DefectDojo/django-DefectDojo/issues
- OWASP Slack: https://owasp.slack.com/messages/project-defect-dojo
- Individual scanner GitHub issues

## Prevention

### Best practices

1. **Regular updates:**
```bash
docker compose pull
docker compose up -d
```

2. **Monitor resources:**
```bash
docker stats
```

3. **Backup data:**
```bash
# Backup database
docker exec defectdojo-postgres pg_dump -U defectdojo defectdojo > backup-$(date +%Y%m%d).sql

# Backup reports
tar -czf reports-backup-$(date +%Y%m%d).tar.gz reports/
```

4. **Clean up regularly:**
```bash
# Weekly cleanup
make clean
docker system prune -f
```

5. **Check logs:**
```bash
# Daily log check
docker compose logs --tail=100
```

## Quick Fixes

### Reset everything

```bash
# Nuclear option - reset everything
docker compose down -v
rm -rf reports/*
docker system prune -a -f
make setup
make up
```

### Restart specific service

```bash
docker compose restart defectdojo
docker compose restart postgres
docker compose restart redis
```

### View real-time logs

```bash
docker compose logs -f defectdojo
docker compose logs -f defectdojo-celery-worker
```

### Check service health

```bash
docker inspect defectdojo --format='{{json .State.Health}}' | jq
```
