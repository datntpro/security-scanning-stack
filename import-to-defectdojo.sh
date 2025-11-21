#!/bin/bash

# Script tự động import tất cả scan results vào DefectDojo

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# DefectDojo Configuration
DD_URL="http://localhost:8000"
DD_USER="admin"
DD_PASS="admin"
PRODUCT_NAME="Security Scan Project"
ENGAGEMENT_NAME="Automated Security Scan $(date +%Y-%m-%d)"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}DefectDojo Import Script${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Kiểm tra DefectDojo đã chạy chưa
echo -e "${YELLOW}Checking DefectDojo status...${NC}"
if ! curl -s -f "${DD_URL}/login" > /dev/null 2>&1; then
    echo -e "${RED}Error: DefectDojo is not running!${NC}"
    echo "Start it with: docker compose up -d defectdojo"
    exit 1
fi
echo -e "${GREEN}✓ DefectDojo is running${NC}"
echo ""

# Lấy API token
echo -e "${YELLOW}Getting API token...${NC}"
API_TOKEN=$(curl -s -X POST "${DD_URL}/api/v2/api-token-auth/" \
    -H "Content-Type: application/json" \
    -d "{\"username\":\"${DD_USER}\",\"password\":\"${DD_PASS}\"}" | \
    grep -o '"token":"[^"]*' | cut -d'"' -f4)

if [ -z "$API_TOKEN" ]; then
    echo -e "${RED}Error: Could not get API token!${NC}"
    echo "Check your credentials or wait for DefectDojo to fully initialize."
    exit 1
fi
echo -e "${GREEN}✓ API token obtained${NC}"
echo ""

# Tạo Product
echo -e "${YELLOW}Creating/Getting Product...${NC}"

# URL encode product name
PRODUCT_NAME_ENCODED=$(echo "$PRODUCT_NAME" | sed 's/ /%20/g')

PRODUCT_RESPONSE=$(curl -s -X GET "${DD_URL}/api/v2/products/?name=${PRODUCT_NAME_ENCODED}" \
    -H "Authorization: Token ${API_TOKEN}")

# Check if jq is available
if command -v jq &> /dev/null; then
    PRODUCT_ID=$(echo "$PRODUCT_RESPONSE" | jq -r '.results[0].id // empty')
else
    PRODUCT_ID=$(echo "$PRODUCT_RESPONSE" | grep -o '"id":[0-9]*' | head -1 | cut -d':' -f2)
fi

if [ -z "$PRODUCT_ID" ]; then
    PRODUCT_CREATE_RESPONSE=$(curl -s -X POST "${DD_URL}/api/v2/products/" \
        -H "Authorization: Token ${API_TOKEN}" \
        -H "Content-Type: application/json" \
        -d "{
            \"name\":\"${PRODUCT_NAME}\",
            \"description\":\"Automated security scanning results\",
            \"prod_type\":1
        }")
    
    if command -v jq &> /dev/null; then
        PRODUCT_ID=$(echo "$PRODUCT_CREATE_RESPONSE" | jq -r '.id // empty')
    else
        PRODUCT_ID=$(echo "$PRODUCT_CREATE_RESPONSE" | grep -o '"id":[0-9]*' | head -1 | cut -d':' -f2)
    fi
    
    if [ -z "$PRODUCT_ID" ]; then
        echo -e "${RED}Error: Could not create product!${NC}"
        echo -e "${RED}Response: ${PRODUCT_CREATE_RESPONSE}${NC}"
        exit 1
    fi
    echo -e "${GREEN}✓ Product created (ID: ${PRODUCT_ID})${NC}"
else
    echo -e "${GREEN}✓ Product found (ID: ${PRODUCT_ID})${NC}"
fi
echo ""

# Tạo Engagement
echo -e "${YELLOW}Creating Engagement...${NC}"

# Calculate dates
TARGET_START=$(date +%Y-%m-%d)
if date -v+7d +%Y-%m-%d &>/dev/null 2>&1; then
    # macOS
    TARGET_END=$(date -v+7d +%Y-%m-%d)
else
    # Linux
    TARGET_END=$(date -d '+7 days' +%Y-%m-%d)
fi

ENGAGEMENT_RESPONSE=$(curl -s -X POST "${DD_URL}/api/v2/engagements/" \
    -H "Authorization: Token ${API_TOKEN}" \
    -H "Content-Type: application/json" \
    -d @- << EOF
{
    "name": "${ENGAGEMENT_NAME}",
    "description": "Automated security scan engagement",
    "product": ${PRODUCT_ID},
    "target_start": "${TARGET_START}",
    "target_end": "${TARGET_END}",
    "engagement_type": "CI/CD",
    "status": "In Progress"
}
EOF
)

if command -v jq &> /dev/null; then
    ENGAGEMENT_ID=$(echo "$ENGAGEMENT_RESPONSE" | jq -r '.id // empty')
else
    ENGAGEMENT_ID=$(echo "$ENGAGEMENT_RESPONSE" | grep -o '"id":[0-9]*' | head -1 | cut -d':' -f2)
fi

if [ -z "$ENGAGEMENT_ID" ]; then
    echo -e "${RED}Error: Could not create engagement!${NC}"
    echo -e "${RED}Response: ${ENGAGEMENT_RESPONSE}${NC}"
    echo ""
    echo "Trying to find existing engagement..."
    
    EXISTING_RESPONSE=$(curl -s -X GET "${DD_URL}/api/v2/engagements/?product=${PRODUCT_ID}" \
        -H "Authorization: Token ${API_TOKEN}")
    
    if command -v jq &> /dev/null; then
        ENGAGEMENT_ID=$(echo "$EXISTING_RESPONSE" | jq -r '.results[0].id // empty')
    else
        ENGAGEMENT_ID=$(echo "$EXISTING_RESPONSE" | grep -o '"id":[0-9]*' | head -1 | cut -d':' -f2)
    fi
    
    if [ -z "$ENGAGEMENT_ID" ]; then
        echo -e "${RED}No existing engagement found. Please check DefectDojo logs.${NC}"
        exit 1
    else
        echo -e "${GREEN}✓ Using existing engagement (ID: ${ENGAGEMENT_ID})${NC}"
    fi
else
    echo -e "${GREEN}✓ Engagement created (ID: ${ENGAGEMENT_ID})${NC}"
fi
echo ""

# Function để import report
import_report() {
    local file=$1
    local scan_type=$2
    local scanner_name=$3
    
    if [ ! -f "$file" ]; then
        echo -e "${YELLOW}  ⊘ ${scanner_name}: File not found${NC}"
        return
    fi
    
    # Kiểm tra file có rỗng không
    if [ ! -s "$file" ]; then
        echo -e "${YELLOW}  ⊘ ${scanner_name}: File is empty${NC}"
        return
    fi
    
    echo -e "${YELLOW}  → Importing ${scanner_name}...${NC}"
    
    # Use yesterday's date to avoid timezone issues
    if date -v-1d +%Y-%m-%d &>/dev/null 2>&1; then
        # macOS
        SCAN_DATE=$(date -v-1d +%Y-%m-%d)
    else
        # Linux
        SCAN_DATE=$(date -d 'yesterday' +%Y-%m-%d)
    fi
    
    RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "${DD_URL}/api/v2/import-scan/" \
        -H "Authorization: Token ${API_TOKEN}" \
        -F "scan_type=${scan_type}" \
        -F "file=@${file}" \
        -F "engagement=${ENGAGEMENT_ID}" \
        -F "active=true" \
        -F "verified=true" \
        -F "scan_date=${SCAN_DATE}" \
        -F "minimum_severity=Info" \
        -F "close_old_findings=false")
    
    HTTP_CODE=$(echo "$RESPONSE" | tail -n 1)
    RESPONSE_BODY=$(echo "$RESPONSE" | sed '$d')
    
    if [ "$HTTP_CODE" = "201" ]; then
        echo -e "${GREEN}  ✓ ${scanner_name} imported successfully${NC}"
    else
        echo -e "${RED}  ✗ ${scanner_name} import failed (HTTP ${HTTP_CODE})${NC}"
        if [ ! -z "$RESPONSE_BODY" ] && [ "$RESPONSE_BODY" != "201" ]; then
            echo -e "${RED}     Error: ${RESPONSE_BODY}${NC}" | head -c 200
            echo ""
        fi
    fi
}

echo -e "${YELLOW}Importing scan results...${NC}"
echo ""

# Import các reports
echo -e "${BLUE}[Secret Detection]${NC}"
import_report "reports/gitleaks-report.json" "Gitleaks Scan" "Gitleaks"
import_report "reports/trufflehog-report.json" "Trufflehog Scan" "TruffleHog"
echo ""

echo -e "${BLUE}[SAST]${NC}"
import_report "reports/semgrep-report.json" "Semgrep JSON Report" "Semgrep"
echo ""

echo -e "${BLUE}[Container Security]${NC}"
import_report "reports/trivy-fs-report.json" "Trivy Scan" "Trivy (Filesystem)"
import_report "reports/trivy-image-report.json" "Trivy Scan" "Trivy (Image)"
import_report "reports/grype-report.json" "Grype JSON" "Grype"
import_report "reports/dockle-report.json" "Dockle JSON" "Dockle"
echo ""

echo -e "${BLUE}[IaC Security]${NC}"
import_report "reports/results_checkov.json" "Checkov Scan" "Checkov"
import_report "reports/tfsec-report.json" "Tfsec Scan" "TFSec"
import_report "reports/results.json" "KICS Scan" "KICS"
echo ""

echo -e "${BLUE}[SCA]${NC}"
import_report "reports/dependency-check-report.json" "Dependency Check Scan" "OWASP Dependency-Check"
import_report "reports/safety-report.json" "Safety Scan" "Safety"
echo ""

echo -e "${BLUE}[DAST]${NC}"
import_report "reports/zap-report.json" "ZAP Scan" "OWASP ZAP"
echo ""

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Import completed!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "Access DefectDojo: ${BLUE}${DD_URL}${NC}"
echo -e "Username: ${BLUE}${DD_USER}${NC}"
echo -e "Password: ${BLUE}${DD_PASS}${NC}"
echo ""
echo -e "Product ID: ${PRODUCT_ID}"
echo -e "Engagement ID: ${ENGAGEMENT_ID}"
echo ""
echo "View your results at:"
echo "${DD_URL}/engagement/${ENGAGEMENT_ID}"
echo ""
