#!/bin/bash

# Script tự động scan toàn bộ source code với tất cả tools

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Security Scanning Stack${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# Kiểm tra thư mục source
if [ ! -d "source" ]; then
    echo -e "${RED}Error: Thư mục 'source' không tồn tại!${NC}"
    echo "Tạo thư mục và copy source code vào đó:"
    echo "  mkdir source"
    echo "  cp -r /path/to/your/project/* source/"
    exit 1
fi

# Tạo thư mục reports nếu chưa có
mkdir -p reports

echo -e "${YELLOW}[1/3] Khởi động infrastructure services...${NC}"
docker compose up -d sonarqube postgres defectdojo owasp-zap
echo -e "${GREEN}✓ Infrastructure services started${NC}"
echo ""

echo -e "${YELLOW}[2/3] Chờ services khởi động hoàn tất...${NC}"
sleep 15
echo -e "${GREEN}✓ Services ready${NC}"
echo ""

echo -e "${YELLOW}[3/3] Chạy security scanners...${NC}"
echo ""

# SAST Scanners
echo -e "${YELLOW}→ Running Semgrep (SAST)...${NC}"
docker compose up semgrep
echo -e "${GREEN}✓ Semgrep completed${NC}"
echo ""

# Secret Detection
echo -e "${YELLOW}→ Running Gitleaks (Secret Detection)...${NC}"
docker compose up gitleaks
echo -e "${GREEN}✓ Gitleaks completed${NC}"
echo ""

echo -e "${YELLOW}→ Running TruffleHog (Secret Detection)...${NC}"
docker compose up trufflehog
echo -e "${GREEN}✓ TruffleHog completed${NC}"
echo ""

# Container Security
echo -e "${YELLOW}→ Running Trivy (Container Security)...${NC}"
docker compose up trivy
echo -e "${GREEN}✓ Trivy completed${NC}"
echo ""

echo -e "${YELLOW}→ Running Grype (Container Security)...${NC}"
docker compose up grype
echo -e "${GREEN}✓ Grype completed${NC}"
echo ""

# IaC Security
echo -e "${YELLOW}→ Running Checkov (IaC Security)...${NC}"
docker compose up checkov
echo -e "${GREEN}✓ Checkov completed${NC}"
echo ""

echo -e "${YELLOW}→ Running TFSec (Terraform Security)...${NC}"
docker compose up tfsec
echo -e "${GREEN}✓ TFSec completed${NC}"
echo ""

echo -e "${YELLOW}→ Running KICS (IaC Security)...${NC}"
docker compose up kics
echo -e "${GREEN}✓ KICS completed${NC}"
echo ""

# SCA
echo -e "${YELLOW}→ Running OWASP Dependency-Check (SCA)...${NC}"
docker compose up dependency-check
echo -e "${GREEN}✓ Dependency-Check completed${NC}"
echo ""

echo -e "${YELLOW}→ Running Safety (Python SCA)...${NC}"
docker compose up safety
echo -e "${GREEN}✓ Safety completed${NC}"
echo ""

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Scan hoàn tất!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "Kết quả scan được lưu trong thư mục: reports/"
echo ""

# Hỏi có muốn import vào DefectDojo không
echo -e "${YELLOW}Bạn có muốn import kết quả vào DefectDojo? (y/n)${NC}"
read -r response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    echo ""
    echo -e "${YELLOW}Importing to DefectDojo...${NC}"
    bash import-to-defectdojo.sh
else
    echo ""
    echo "Bạn có thể import sau bằng lệnh:"
    echo "  bash import-to-defectdojo.sh"
fi

echo ""
echo "Các services đang chạy:"
echo "  - SonarQube:    http://localhost:9000 (admin/admin)"
echo "  - OWASP ZAP:    http://localhost:8080"
echo "  - DefectDojo:   http://localhost:8000 (admin/admin)"
echo ""
echo "Để xem reports:"
echo "  ls -lh reports/"
echo ""
echo "Để dừng tất cả services:"
echo "  docker compose down"
echo ""
