#!/bin/bash

# Script hiển thị tất cả findings từ DefectDojo

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

DD_URL="http://localhost:8000"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}DefectDojo Findings Summary${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Get API token
TOKEN=$(curl -s -X POST "${DD_URL}/api/v2/api-token-auth/" \
    -H "Content-Type: application/json" \
    -d '{"username":"admin","password":"admin"}' | jq -r '.token')

if [ -z "$TOKEN" ] || [ "$TOKEN" = "null" ]; then
    echo -e "${RED}Error: Could not get API token!${NC}"
    exit 1
fi

# Get total findings
TOTAL=$(curl -s -X GET "${DD_URL}/api/v2/findings/" \
    -H "Authorization: Token ${TOKEN}" | jq -r '.count')

echo -e "${GREEN}Total Findings: ${TOTAL}${NC}"
echo ""

# Get findings by severity
echo -e "${YELLOW}Findings by Severity:${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

CRITICAL=$(curl -s -X GET "${DD_URL}/api/v2/findings/?severity=Critical" \
    -H "Authorization: Token ${TOKEN}" | jq -r '.count')
echo -e "${RED}  Critical: ${CRITICAL}${NC}"

HIGH=$(curl -s -X GET "${DD_URL}/api/v2/findings/?severity=High" \
    -H "Authorization: Token ${TOKEN}" | jq -r '.count')
echo -e "${MAGENTA}  High:     ${HIGH}${NC}"

MEDIUM=$(curl -s -X GET "${DD_URL}/api/v2/findings/?severity=Medium" \
    -H "Authorization: Token ${TOKEN}" | jq -r '.count')
echo -e "${YELLOW}  Medium:   ${MEDIUM}${NC}"

LOW=$(curl -s -X GET "${DD_URL}/api/v2/findings/?severity=Low" \
    -H "Authorization: Token ${TOKEN}" | jq -r '.count')
echo -e "${CYAN}  Low:      ${LOW}${NC}"

INFO=$(curl -s -X GET "${DD_URL}/api/v2/findings/?severity=Info" \
    -H "Authorization: Token ${TOKEN}" | jq -r '.count')
echo -e "  Info:     ${INFO}"

echo ""

# Get findings by test type
echo -e "${YELLOW}Findings by Scanner:${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

TESTS=$(curl -s -X GET "${DD_URL}/api/v2/tests/" \
    -H "Authorization: Token ${TOKEN}" | jq -r '.results[] | "\(.test_type_name): \(.findings_count)"')

echo "$TESTS" | while read line; do
    echo "  $line"
done

echo ""

# Show top 10 findings
echo -e "${YELLOW}Top 10 Critical/High Findings:${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

curl -s -X GET "${DD_URL}/api/v2/findings/?severity=Critical&severity=High&limit=10" \
    -H "Authorization: Token ${TOKEN}" | \
    jq -r '.results[] | "\(.severity) | \(.title) | \(.file_path // "N/A")"' | \
    while IFS='|' read severity title file; do
        if [[ "$severity" == *"Critical"* ]]; then
            echo -e "${RED}  [CRITICAL]${NC} $title"
        else
            echo -e "${MAGENTA}  [HIGH]${NC} $title"
        fi
        echo -e "    ${CYAN}File:${NC} $file"
        echo ""
    done

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}View all findings in DefectDojo:${NC}"
echo -e "${BLUE}${DD_URL}/finding${NC}"
echo ""
echo -e "Or run: ${CYAN}make open-defectdojo${NC}"
echo ""
