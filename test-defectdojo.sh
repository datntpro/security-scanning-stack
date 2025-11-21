#!/bin/bash

# Script test DefectDojo

echo "Testing DefectDojo..."
echo ""

# Test web UI
echo "1. Testing Web UI (http://localhost:8000)..."
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8000/login)
if [ "$HTTP_CODE" = "200" ]; then
    echo "   ✅ Web UI is accessible (HTTP $HTTP_CODE)"
else
    echo "   ❌ Web UI failed (HTTP $HTTP_CODE)"
    exit 1
fi

# Test API
echo ""
echo "2. Testing API..."
API_RESPONSE=$(curl -s -X POST http://localhost:8000/api/v2/api-token-auth/ \
    -H "Content-Type: application/json" \
    -d '{"username":"admin","password":"admin"}')

if echo "$API_RESPONSE" | grep -q "token"; then
    echo "   ✅ API authentication successful"
    TOKEN=$(echo "$API_RESPONSE" | grep -o '"token":"[^"]*' | cut -d'"' -f4)
    echo "   Token: ${TOKEN:0:20}..."
else
    echo "   ❌ API authentication failed"
    echo "   Response: $API_RESPONSE"
    exit 1
fi

# Test API endpoints
echo ""
echo "3. Testing API endpoints..."
PRODUCTS=$(curl -s -X GET http://localhost:8000/api/v2/products/ \
    -H "Authorization: Token $TOKEN")

if echo "$PRODUCTS" | grep -q "count"; then
    echo "   ✅ Products API working"
else
    echo "   ❌ Products API failed"
fi

# Check services
echo ""
echo "4. Checking services status..."
docker compose ps --format "table {{.Service}}\t{{.Status}}" | grep defectdojo

echo ""
echo "=========================================="
echo "✅ DefectDojo is ready!"
echo "=========================================="
echo ""
echo "Access DefectDojo at: http://localhost:8000"
echo "Username: admin"
echo "Password: admin"
echo ""
echo "Next steps:"
echo "  1. Run scans: make scan"
echo "  2. Import results: make import"
echo "  3. View in DefectDojo: http://localhost:8000"
echo ""
