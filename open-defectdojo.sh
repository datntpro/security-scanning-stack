#!/bin/bash

echo "Opening DefectDojo in your browser..."
echo ""
echo "URL: http://localhost:8000"
echo "Username: admin"
echo "Password: admin"
echo ""

# Detect OS and open browser
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    open http://localhost:8000
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Linux
    xdg-open http://localhost:8000 2>/dev/null || echo "Please open http://localhost:8000 in your browser"
else
    echo "Please open http://localhost:8000 in your browser"
fi
