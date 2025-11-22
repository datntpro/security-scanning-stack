.PHONY: help setup up down logs scan clean scan-secrets scan-sast scan-iac scan-container scan-sca

help: ## Hiển thị help
	@echo "Security Scanning Stack - Available Commands:"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}'

setup: ## Tạo thư mục cần thiết
	@echo "Creating directories..."
	@mkdir -p source reports
	@echo "✓ Directories created"
	@echo ""
	@echo "Next steps:"
	@echo "  1. Copy your source code to 'source/' directory"
	@echo "  2. Run 'make up' to start services"
	@echo "  3. Run 'make scan' to scan your code"

up: ## Khởi động tất cả services
	@echo "Starting all services..."
	@docker compose up -d
	@echo "✓ Services started"
	@echo ""
	@echo "Access points:"
	@echo "  - SonarQube:  http://localhost:9000"
	@echo "  - OWASP ZAP:  http://localhost:8080"
	@echo "  - DefectDojo: http://localhost:8000"

down: ## Dừng tất cả services
	@echo "Stopping all services..."
	@docker compose down
	@echo "✓ Services stopped"

logs: ## Xem logs của tất cả services
	@docker compose logs -f

scan: ## Chạy tất cả scanners
	@bash scan-all.sh

scan-secrets: ## Chỉ scan secrets (Gitleaks, TruffleHog)
	@echo "Running secret detection..."
	@docker compose up gitleaks
	@docker compose up trufflehog
	@echo "✓ Secret detection completed"

scan-sast: ## Chỉ scan SAST (Semgrep)
	@echo "Running SAST scan..."
	@docker compose up semgrep
	@echo "✓ SAST scan completed"

scan-iac: ## Chỉ scan IaC (Checkov, TFSec, KICS)
	@echo "Running IaC security scan..."
	@docker compose up checkov
	@docker compose up tfsec
	@docker compose up kics
	@echo "✓ IaC scan completed"

scan-container: ## Chỉ scan containers (Trivy, Grype)
	@echo "Running container security scan..."
	@docker compose up trivy
	@docker compose up grype
	@echo "✓ Container scan completed"

scan-sca: ## Chỉ scan dependencies (Dependency-Check, Safety)
	@echo "Running SCA scan..."
	@docker compose up dependency-check
	@docker compose up safety
	@echo "✓ SCA scan completed"

reports: ## Liệt kê tất cả reports
	@echo "Available reports:"
	@ls -lh reports/ 2>/dev/null || echo "No reports found. Run 'make scan' first."

clean: ## Xóa reports và dừng services
	@echo "Cleaning up..."
	@docker compose down
	@rm -rf reports/*
	@echo "✓ Cleanup completed"

clean-all: ## Xóa tất cả (bao gồm volumes)
	@echo "Cleaning up everything..."
	@docker compose down -v
	@rm -rf reports/*
	@echo "✓ Full cleanup completed"

status: ## Kiểm tra trạng thái services
	@docker compose ps

import: ## Import reports vào DefectDojo
	@echo "Ensuring DefectDojo is running..."
	@docker compose up -d defectdojo-nginx 2>/dev/null || true
	@sleep 2
	@bash import-to-defectdojo.sh

defectdojo-init: ## Khởi tạo DefectDojo lần đầu
	@echo "Initializing DefectDojo..."
	@docker compose up -d postgres redis
	@sleep 5
	@docker compose up defectdojo-initializer
	@docker compose up -d defectdojo defectdojo-celery-beat defectdojo-celery-worker defectdojo-nginx
	@echo "Waiting for DefectDojo to be ready..."
	@sleep 10
	@docker exec defectdojo python manage.py shell -c "from django.contrib.auth.models import User; u = User.objects.get(username='admin'); u.set_password('admin'); u.save()" 2>/dev/null || true
	@echo "✓ DefectDojo initialized"
	@echo ""
	@echo "Access DefectDojo at: http://localhost:8000"
	@echo "Username: admin"
	@echo "Password: admin"

open-defectdojo: ## Mở DefectDojo trong browser
	@echo "Opening DefectDojo..."
	@open http://localhost:8000 2>/dev/null || xdg-open http://localhost:8000 2>/dev/null || echo "Please open http://localhost:8000 in your browser"
	@echo ""
	@echo "Login credentials:"
	@echo "  Username: admin"
	@echo "  Password: admin"

report-vi: ## Tạo báo cáo HTML tiếng Việt (chi tiết)
	@bash generate-vietnamese-report.sh
	@open bao-cao-bao-mat.html 2>/dev/null || xdg-open bao-cao-bao-mat.html 2>/dev/null || echo "Vui lòng mở file bao-cao-bao-mat.html trong browser"
