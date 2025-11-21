#!/bin/bash

# Script tạo HTML report từ scan results

DD_URL="http://localhost:8000"
OUTPUT_FILE="security-report.html"

echo "Generating security report..."

# Get API token
TOKEN=$(curl -s -X POST "${DD_URL}/api/v2/api-token-auth/" \
    -H "Content-Type: application/json" \
    -d '{"username":"admin","password":"admin"}' | jq -r '.token')

# Get findings data
TOTAL=$(curl -s -X GET "${DD_URL}/api/v2/findings/" -H "Authorization: Token ${TOKEN}" | jq -r '.count')
CRITICAL=$(curl -s -X GET "${DD_URL}/api/v2/findings/?severity=Critical" -H "Authorization: Token ${TOKEN}" | jq -r '.count')
HIGH=$(curl -s -X GET "${DD_URL}/api/v2/findings/?severity=High" -H "Authorization: Token ${TOKEN}" | jq -r '.count')
MEDIUM=$(curl -s -X GET "${DD_URL}/api/v2/findings/?severity=Medium" -H "Authorization: Token ${TOKEN}" | jq -r '.count')
LOW=$(curl -s -X GET "${DD_URL}/api/v2/findings/?severity=Low" -H "Authorization: Token ${TOKEN}" | jq -r '.count')

# Get top findings
TOP_FINDINGS=$(curl -s -X GET "${DD_URL}/api/v2/findings/?severity=High&limit=20" \
    -H "Authorization: Token ${TOKEN}" | \
    jq -r '.results[] | "<tr><td class=\"severity-\(.severity | ascii_downcase)\">\(.severity)</td><td>\(.title)</td><td>\(.file_path // "N/A")</td><td>\(.line // "N/A")</td></tr>"')

# Generate HTML
cat > "$OUTPUT_FILE" << EOF
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Security Scan Report</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            padding: 20px;
            color: #333;
        }
        .container {
            max-width: 1200px;
            margin: 0 auto;
            background: white;
            border-radius: 20px;
            box-shadow: 0 20px 60px rgba(0,0,0,0.3);
            overflow: hidden;
        }
        .header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 40px;
            text-align: center;
        }
        .header h1 {
            font-size: 2.5em;
            margin-bottom: 10px;
        }
        .header p {
            font-size: 1.2em;
            opacity: 0.9;
        }
        .stats {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
            padding: 40px;
            background: #f8f9fa;
        }
        .stat-card {
            background: white;
            padding: 30px;
            border-radius: 15px;
            text-align: center;
            box-shadow: 0 4px 6px rgba(0,0,0,0.1);
            transition: transform 0.3s;
        }
        .stat-card:hover {
            transform: translateY(-5px);
        }
        .stat-number {
            font-size: 3em;
            font-weight: bold;
            margin-bottom: 10px;
        }
        .stat-label {
            font-size: 1.1em;
            color: #666;
            text-transform: uppercase;
            letter-spacing: 1px;
        }
        .severity-critical { color: #dc3545; }
        .severity-high { color: #fd7e14; }
        .severity-medium { color: #ffc107; }
        .severity-low { color: #28a745; }
        .severity-info { color: #17a2b8; }
        .content {
            padding: 40px;
        }
        .section {
            margin-bottom: 40px;
        }
        .section h2 {
            font-size: 2em;
            margin-bottom: 20px;
            color: #667eea;
            border-bottom: 3px solid #667eea;
            padding-bottom: 10px;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            background: white;
            border-radius: 10px;
            overflow: hidden;
            box-shadow: 0 4px 6px rgba(0,0,0,0.1);
        }
        th {
            background: #667eea;
            color: white;
            padding: 15px;
            text-align: left;
            font-weight: 600;
        }
        td {
            padding: 15px;
            border-bottom: 1px solid #eee;
        }
        tr:hover {
            background: #f8f9fa;
        }
        .footer {
            background: #2c3e50;
            color: white;
            padding: 30px;
            text-align: center;
        }
        .footer a {
            color: #667eea;
            text-decoration: none;
        }
        .badge {
            display: inline-block;
            padding: 5px 15px;
            border-radius: 20px;
            font-size: 0.9em;
            font-weight: bold;
        }
        .badge-critical { background: #dc3545; color: white; }
        .badge-high { background: #fd7e14; color: white; }
        .badge-medium { background: #ffc107; color: #333; }
        .badge-low { background: #28a745; color: white; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🔒 Security Scan Report</h1>
            <p>Comprehensive Security Analysis</p>
            <p>Generated: $(date '+%Y-%m-%d %H:%M:%S')</p>
        </div>

        <div class="stats">
            <div class="stat-card">
                <div class="stat-number">${TOTAL}</div>
                <div class="stat-label">Total Findings</div>
            </div>
            <div class="stat-card">
                <div class="stat-number severity-critical">${CRITICAL}</div>
                <div class="stat-label">Critical</div>
            </div>
            <div class="stat-card">
                <div class="stat-number severity-high">${HIGH}</div>
                <div class="stat-label">High</div>
            </div>
            <div class="stat-card">
                <div class="stat-number severity-medium">${MEDIUM}</div>
                <div class="stat-label">Medium</div>
            </div>
            <div class="stat-card">
                <div class="stat-number severity-low">${LOW}</div>
                <div class="stat-label">Low</div>
            </div>
        </div>

        <div class="content">
            <div class="section">
                <h2>📊 Summary</h2>
                <p style="font-size: 1.2em; line-height: 1.8; color: #555;">
                    Security scan đã phát hiện <strong>${TOTAL} lỗ hổng bảo mật</strong> trong source code của bạn.
                    Trong đó có <strong class="severity-high">${HIGH} lỗ hổng mức HIGH</strong> cần được ưu tiên xử lý ngay.
                </p>
                <br>
                <p style="font-size: 1.1em; line-height: 1.8; color: #555;">
                    Các lỗ hổng bao gồm:
                </p>
                <ul style="font-size: 1.1em; line-height: 2; color: #555; margin-left: 40px; margin-top: 10px;">
                    <li>🔴 SQL Injection vulnerabilities</li>
                    <li>🔴 Path Traversal issues</li>
                    <li>🔴 Hardcoded secrets (API keys, JWT tokens, passwords)</li>
                    <li>🟡 Security misconfigurations</li>
                    <li>🟡 Weak cryptography</li>
                    <li>🟡 Missing security headers</li>
                </ul>
            </div>

            <div class="section">
                <h2>🔥 Top High Severity Findings</h2>
                <table>
                    <thead>
                        <tr>
                            <th>Severity</th>
                            <th>Issue</th>
                            <th>File</th>
                            <th>Line</th>
                        </tr>
                    </thead>
                    <tbody>
                        ${TOP_FINDINGS}
                    </tbody>
                </table>
            </div>

            <div class="section">
                <h2>🎯 Recommended Actions</h2>
                <div style="background: #f8f9fa; padding: 30px; border-radius: 15px; border-left: 5px solid #667eea;">
                    <h3 style="color: #667eea; margin-bottom: 15px;">Immediate Actions (High Priority)</h3>
                    <ol style="font-size: 1.1em; line-height: 2; color: #555; margin-left: 20px;">
                        <li>Fix all SQL Injection vulnerabilities - use parameterized queries</li>
                        <li>Remove hardcoded secrets - use environment variables</li>
                        <li>Fix Path Traversal issues - validate and sanitize file paths</li>
                        <li>Review and fix security misconfigurations</li>
                    </ol>
                    <br>
                    <h3 style="color: #667eea; margin-bottom: 15px;">Next Steps</h3>
                    <ol style="font-size: 1.1em; line-height: 2; color: #555; margin-left: 20px;">
                        <li>Review all findings in DefectDojo: <a href="${DD_URL}/finding" target="_blank">${DD_URL}/finding</a></li>
                        <li>Assign findings to developers</li>
                        <li>Track remediation progress</li>
                        <li>Re-scan after fixes</li>
                        <li>Generate compliance reports</li>
                    </ol>
                </div>
            </div>
        </div>

        <div class="footer">
            <p>Generated by Security Scanning Stack</p>
            <p>View detailed findings in <a href="${DD_URL}" target="_blank">DefectDojo</a></p>
        </div>
    </div>
</body>
</html>
EOF

echo "✓ Report generated: $OUTPUT_FILE"
echo ""
echo "Open report:"
echo "  open $OUTPUT_FILE"
echo ""
