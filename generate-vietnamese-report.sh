#!/bin/bash

# Script tạo báo cáo bảo mật chi tiết bằng tiếng Việt

DD_URL="http://localhost:8000"
OUTPUT_FILE="bao-cao-bao-mat.html"

echo "Đang tạo báo cáo bảo mật chi tiết..."

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

# Get detailed findings
curl -s -X GET "${DD_URL}/api/v2/findings/?severity=High&limit=100" \
    -H "Authorization: Token ${TOKEN}" > /tmp/high_findings.json

curl -s -X GET "${DD_URL}/api/v2/findings/?severity=Medium&limit=50" \
    -H "Authorization: Token ${TOKEN}" > /tmp/medium_findings.json

# Start HTML generation
cat > "$OUTPUT_FILE" << 'HTMLSTART'
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Báo Cáo Bảo Mật Source Code</title>
    <style>
HTMLSTART

# Append CSS
cat >> "$OUTPUT_FILE" << 'CSS'
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            padding: 20px;
            color: #333;
            line-height: 1.6;
        }
        .container {
            max-width: 1400px;
            margin: 0 auto;
            background: white;
            border-radius: 20px;
            box-shadow: 0 20px 60px rgba(0,0,0,0.3);
            overflow: hidden;
        }
        .header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 50px;
            text-align: center;
        }
        .header h1 {
            font-size: 3em;
            margin-bottom: 15px;
            text-shadow: 2px 2px 4px rgba(0,0,0,0.2);
        }
        .header p {
            font-size: 1.3em;
            opacity: 0.95;
        }
        .stats {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
            gap: 25px;
            padding: 50px;
            background: #f8f9fa;
        }
        .stat-card {
            background: white;
            padding: 35px;
            border-radius: 15px;
            text-align: center;
            box-shadow: 0 4px 15px rgba(0,0,0,0.1);
            transition: all 0.3s;
            border-top: 4px solid;
        }
        .stat-card:hover {
            transform: translateY(-8px);
            box-shadow: 0 8px 25px rgba(0,0,0,0.15);
        }
        .stat-card.critical { border-top-color: #dc3545; }
        .stat-card.high { border-top-color: #fd7e14; }
        .stat-card.medium { border-top-color: #ffc107; }
        .stat-card.low { border-top-color: #28a745; }
        .stat-card.total { border-top-color: #667eea; }
        .stat-number {
            font-size: 3.5em;
            font-weight: bold;
            margin-bottom: 10px;
        }
        .stat-label {
            font-size: 1.2em;
            color: #666;
            text-transform: uppercase;
            letter-spacing: 1.5px;
            font-weight: 600;
        }
        .content {
            padding: 50px;
        }
        .section {
            margin-bottom: 50px;
        }
        .section h2 {
            font-size: 2.2em;
            margin-bottom: 25px;
            color: #667eea;
            border-bottom: 4px solid #667eea;
            padding-bottom: 15px;
            display: flex;
            align-items: center;
        }
        .section h2::before {
            content: '🔍';
            margin-right: 15px;
            font-size: 1.2em;
        }
        .vulnerability-table {
            width: 100%;
            border-collapse: collapse;
            background: white;
            border-radius: 10px;
            overflow: hidden;
            box-shadow: 0 4px 15px rgba(0,0,0,0.1);
            margin-bottom: 30px;
        }
        .vulnerability-table th {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 18px;
            text-align: left;
            font-weight: 600;
            font-size: 1.05em;
        }
        .vulnerability-table td {
            padding: 18px;
            border-bottom: 1px solid #eee;
            vertical-align: top;
        }
        .vulnerability-table tr:hover {
            background: #f8f9fa;
        }
        .vulnerability-table tr:last-child td {
            border-bottom: none;
        }
        .severity-badge {
            display: inline-block;
            padding: 6px 16px;
            border-radius: 20px;
            font-size: 0.9em;
            font-weight: bold;
            text-transform: uppercase;
        }
        .severity-critical { background: #dc3545; color: white; }
        .severity-high { background: #fd7e14; color: white; }
        .severity-medium { background: #ffc107; color: #333; }
        .severity-low { background: #28a745; color: white; }
        .file-path {
            font-family: 'Courier New', monospace;
            background: #f4f4f4;
            padding: 8px 12px;
            border-radius: 5px;
            font-size: 0.9em;
            color: #d63384;
            word-break: break-all;
        }
        .fix-guide {
            background: #e7f3ff;
            border-left: 4px solid #0066cc;
            padding: 15px 20px;
            margin-top: 10px;
            border-radius: 5px;
        }
        .fix-guide h4 {
            color: #0066cc;
            margin-bottom: 10px;
            font-size: 1.1em;
        }
        .fix-guide ul {
            margin-left: 20px;
            margin-top: 8px;
        }
        .fix-guide li {
            margin-bottom: 8px;
            line-height: 1.6;
        }
        .code-example {
            background: #2d2d2d;
            color: #f8f8f2;
            padding: 15px;
            border-radius: 8px;
            font-family: 'Courier New', monospace;
            font-size: 0.9em;
            overflow-x: auto;
            margin: 10px 0;
        }
        .code-good { border-left: 4px solid #28a745; }
        .code-bad { border-left: 4px solid #dc3545; }
        .summary-box {
            background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
            color: white;
            padding: 35px;
            border-radius: 15px;
            margin-bottom: 40px;
            box-shadow: 0 8px 20px rgba(0,0,0,0.15);
        }
        .summary-box h3 {
            font-size: 1.8em;
            margin-bottom: 20px;
        }
        .summary-box ul {
            font-size: 1.15em;
            line-height: 2;
            list-style: none;
        }
        .summary-box li::before {
            content: '✓ ';
            font-weight: bold;
            margin-right: 10px;
        }
        .footer {
            background: #2c3e50;
            color: white;
            padding: 40px;
            text-align: center;
        }
        .footer a {
            color: #667eea;
            text-decoration: none;
            font-weight: bold;
        }
        .priority-high {
            background: #fff3cd;
            border-left: 5px solid #ffc107;
            padding: 20px;
            margin: 20px 0;
            border-radius: 8px;
        }
        .priority-high h3 {
            color: #856404;
            margin-bottom: 15px;
        }
        @media print {
            body { background: white; padding: 0; }
            .container { box-shadow: none; }
        }
    </style>
</head>
<body>
CSS

# Append HTML body start
cat >> "$OUTPUT_FILE" << HTMLBODY
    <div class="container">
        <div class="header">
            <h1>🔒 BÁO CÁO BẢO MẬT SOURCE CODE</h1>
            <p>Phân Tích Chi Tiết Lỗ Hổng Bảo Mật</p>
            <p>Ngày tạo: $(date '+%d/%m/%Y %H:%M:%S')</p>
        </div>

        <div class="stats">
            <div class="stat-card total">
                <div class="stat-number" style="color: #667eea;">${TOTAL}</div>
                <div class="stat-label">Tổng Lỗ Hổng</div>
            </div>
            <div class="stat-card critical">
                <div class="stat-number" style="color: #dc3545;">${CRITICAL}</div>
                <div class="stat-label">Nghiêm Trọng</div>
            </div>
            <div class="stat-card high">
                <div class="stat-number" style="color: #fd7e14;">${HIGH}</div>
                <div class="stat-label">Cao</div>
            </div>
            <div class="stat-card medium">
                <div class="stat-number" style="color: #ffc107;">${MEDIUM}</div>
                <div class="stat-label">Trung Bình</div>
            </div>
            <div class="stat-card low">
                <div class="stat-number" style="color: #28a745;">${LOW}</div>
                <div class="stat-label">Thấp</div>
            </div>
        </div>

        <div class="content">
            <div class="summary-box">
                <h3>📊 Tóm Tắt Kết Quả Quét</h3>
                <ul>
                    <li>Đã quét <strong>${TOTAL} lỗ hổng bảo mật</strong> trong source code</li>
                    <li>Phát hiện <strong>${HIGH} lỗ hổng mức ĐỘ CAO</strong> cần xử lý ngay</li>
                    <li>Bao gồm: SQL Injection, Path Traversal, Hardcoded Secrets</li>
                    <li>Tất cả lỗ hổng đều có hướng dẫn fix chi tiết bên dưới</li>
                </ul>
            </div>

            <div class="priority-high">
                <h3>⚠️ Ưu Tiên Xử Lý</h3>
                <p><strong>Cần fix ngay:</strong> ${HIGH} lỗ hổng mức cao có thể bị khai thác để tấn công hệ thống.</p>
                <p><strong>Thời gian khuyến nghị:</strong> Trong vòng 7 ngày</p>
            </div>
HTMLBODY

# Generate HIGH severity findings table
cat >> "$OUTPUT_FILE" << 'HIGHSECTION'
            <div class="section">
                <h2>Lỗ Hổng Mức Độ CAO</h2>
                <table class="vulnerability-table">
                    <thead>
                        <tr>
                            <th style="width: 15%;">Mức Độ</th>
                            <th style="width: 25%;">Loại Lỗ Hổng</th>
                            <th style="width: 30%;">File</th>
                            <th style="width: 30%;">Hướng Dẫn Fix</th>
                        </tr>
                    </thead>
                    <tbody>
HIGHSECTION

# Process HIGH findings
jq -r '.results[] | @json' /tmp/high_findings.json 2>/dev/null | head -30 | while read -r finding; do
    title=$(echo "$finding" | jq -r '.title // "N/A"')
    file=$(echo "$finding" | jq -r '.file_path // "N/A"')
    line=$(echo "$finding" | jq -r '.line // "N/A"')
    
    # Determine vulnerability type and fix guide in Vietnamese
    if [[ "$title" == *"sql"* ]] || [[ "$title" == *"SQL"* ]]; then
        vuln_type="SQL Injection"
        fix_guide="<div class='fix-guide'>
            <h4>Cách Khắc Phục:</h4>
            <ul>
                <li><strong>Sử dụng Prepared Statements:</strong> Thay vì nối chuỗi SQL, dùng parameterized queries</li>
                <li><strong>Validate Input:</strong> Kiểm tra và làm sạch dữ liệu đầu vào</li>
                <li><strong>Sử dụng ORM:</strong> Dùng JPA/Hibernate thay vì raw SQL</li>
            </ul>
            <div class='code-example code-bad'>❌ Code Lỗi:<br>String query = \"SELECT * FROM users WHERE id = '\" + userId + \"'\";</div>
            <div class='code-example code-good'>✅ Code Đúng:<br>PreparedStatement ps = conn.prepareStatement(\"SELECT * FROM users WHERE id = ?\");<br>ps.setString(1, userId);</div>
        </div>"
    elif [[ "$title" == *"path-traversal"* ]] || [[ "$title" == *"Path"* ]]; then
        vuln_type="Path Traversal"
        fix_guide="<div class='fix-guide'>
            <h4>Cách Khắc Phục:</h4>
            <ul>
                <li><strong>Validate đường dẫn:</strong> Kiểm tra file path không chứa ../ hoặc ký tự đặc biệt</li>
                <li><strong>Whitelist:</strong> Chỉ cho phép truy cập các file trong danh sách an toàn</li>
                <li><strong>Canonicalize:</strong> Chuẩn hóa đường dẫn trước khi sử dụng</li>
            </ul>
            <div class='code-example code-bad'>❌ Code Lỗi:<br>File file = new File(uploadDir, userInput);</div>
            <div class='code-example code-good'>✅ Code Đúng:<br>Path basePath = Paths.get(uploadDir).toRealPath();<br>Path filePath = basePath.resolve(userInput).normalize();<br>if (!filePath.startsWith(basePath)) throw new SecurityException();</div>
        </div>"
    elif [[ "$title" == *"jwt"* ]] || [[ "$title" == *"JWT"* ]] || [[ "$title" == *"token"* ]]; then
        vuln_type="Hardcoded JWT Token"
        fix_guide="<div class='fix-guide'>
            <h4>Cách Khắc Phục:</h4>
            <ul>
                <li><strong>Xóa token:</strong> Không hardcode JWT token trong source code</li>
                <li><strong>Dùng biến môi trường:</strong> Lưu secret key trong environment variables</li>
                <li><strong>Rotate keys:</strong> Thay đổi secret key định kỳ</li>
            </ul>
            <div class='code-example code-bad'>❌ Code Lỗi:<br>String token = \"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...\";</div>
            <div class='code-example code-good'>✅ Code Đúng:<br>String secretKey = System.getenv(\"JWT_SECRET_KEY\");<br>// Generate token dynamically</div>
        </div>"
    elif [[ "$title" == *"api-key"* ]] || [[ "$title" == *"secret"* ]]; then
        vuln_type="Hardcoded API Key/Secret"
        fix_guide="<div class='fix-guide'>
            <h4>Cách Khắc Phục:</h4>
            <ul>
                <li><strong>Xóa khỏi code:</strong> Không lưu API key trong source code</li>
                <li><strong>Environment variables:</strong> Dùng biến môi trường hoặc secret manager</li>
                <li><strong>Revoke key:</strong> Thu hồi API key cũ và tạo key mới</li>
            </ul>
            <div class='code-example code-bad'>❌ Code Lỗi:<br>String apiKey = \"sk-1234567890abcdef\";</div>
            <div class='code-example code-good'>✅ Code Đúng:<br>String apiKey = System.getenv(\"API_KEY\");</div>
        </div>"
    elif [[ "$title" == *"weak-random"* ]] || [[ "$title" == *"random"* ]]; then
        vuln_type="Weak Random Number"
        fix_guide="<div class='fix-guide'>
            <h4>Cách Khắc Phục:</h4>
            <ul>
                <li><strong>Dùng SecureRandom:</strong> Thay Math.random() bằng SecureRandom</li>
                <li><strong>Cryptographically secure:</strong> Dùng cho mục đích bảo mật</li>
            </ul>
            <div class='code-example code-bad'>❌ Code Lỗi:<br>int random = (int)(Math.random() * 1000);</div>
            <div class='code-example code-good'>✅ Code Đúng:<br>SecureRandom secureRandom = new SecureRandom();<br>int random = secureRandom.nextInt(1000);</div>
        </div>"
    elif [[ "$title" == *"url-host"* ]] || [[ "$title" == *"ssrf"* ]]; then
        vuln_type="SSRF / Tainted URL"
        fix_guide="<div class='fix-guide'>
            <h4>Cách Khắc Phục:</h4>
            <ul>
                <li><strong>Validate URL:</strong> Kiểm tra URL không trỏ đến internal network</li>
                <li><strong>Whitelist domains:</strong> Chỉ cho phép kết nối đến domain an toàn</li>
                <li><strong>Disable redirects:</strong> Tắt auto-redirect để tránh bypass</li>
            </ul>
            <div class='code-example code-bad'>❌ Code Lỗi:<br>URL url = new URL(userInput);<br>url.openConnection();</div>
            <div class='code-example code-good'>✅ Code Đúng:<br>if (!isAllowedDomain(userInput)) throw new SecurityException();<br>URL url = new URL(userInput);</div>
        </div>"
    else
        vuln_type="Security Misconfiguration"
        fix_guide="<div class='fix-guide'>
            <h4>Cách Khắc Phục:</h4>
            <ul>
                <li><strong>Review cấu hình:</strong> Kiểm tra lại security settings</li>
                <li><strong>Follow best practices:</strong> Áp dụng security guidelines</li>
                <li><strong>Update dependencies:</strong> Cập nhật thư viện lên phiên bản mới</li>
            </ul>
        </div>"
    fi
    
    cat >> "$OUTPUT_FILE" << FINDINGROW
                        <tr>
                            <td><span class="severity-badge severity-high">CAO</span></td>
                            <td><strong>${vuln_type}</strong><br><small style="color: #666;">${title}</small></td>
                            <td>
                                <div class="file-path">${file}</div>
                                <small style="color: #666;">Dòng: ${line}</small>
                            </td>
                            <td>${fix_guide}</td>
                        </tr>
FINDINGROW
done

cat >> "$OUTPUT_FILE" << 'ENDHIGH'
                    </tbody>
                </table>
            </div>
ENDHIGH

# Add recommendations section
cat >> "$OUTPUT_FILE" << 'RECOMMENDATIONS'
            <div class="section">
                <h2>Khuyến Nghị Hành Động</h2>
                
                <div style="background: #fff3cd; border-left: 5px solid #ffc107; padding: 25px; margin-bottom: 25px; border-radius: 8px;">
                    <h3 style="color: #856404; margin-bottom: 15px;">🔥 Ưu Tiên Cao - Cần Fix Ngay (7 ngày)</h3>
                    <ol style="margin-left: 20px; line-height: 2;">
                        <li><strong>SQL Injection:</strong> Fix tất cả các trường hợp sử dụng string concatenation trong SQL queries. Chuyển sang dùng Prepared Statements hoặc ORM.</li>
                        <li><strong>Hardcoded Secrets:</strong> Xóa tất cả API keys, JWT tokens, passwords khỏi source code. Di chuyển sang environment variables hoặc secret manager (AWS Secrets Manager, Azure Key Vault).</li>
                        <li><strong>Path Traversal:</strong> Validate và sanitize tất cả file paths từ user input. Implement whitelist cho các file được phép truy cập.</li>
                    </ol>
                </div>

                <div style="background: #d1ecf1; border-left: 5px solid #0c5460; padding: 25px; margin-bottom: 25px; border-radius: 8px;">
                    <h3 style="color: #0c5460; margin-bottom: 15px;">⚡ Ưu Tiên Trung Bình (30 ngày)</h3>
                    <ol style="margin-left: 20px; line-height: 2;">
                        <li><strong>Security Misconfigurations:</strong> Review và fix các cấu hình bảo mật không đúng trong Spring Security, CORS, CSP headers.</li>
                        <li><strong>Weak Cryptography:</strong> Thay thế Math.random() bằng SecureRandom cho các mục đích bảo mật.</li>
                        <li><strong>Missing Security Headers:</strong> Thêm các security headers: X-Frame-Options, X-Content-Type-Options, CSP.</li>
                    </ol>
                </div>

                <div style="background: #d4edda; border-left: 5px solid #155724; padding: 25px; border-radius: 8px;">
                    <h3 style="color: #155724; margin-bottom: 15px;">📋 Quy Trình Khắc Phục</h3>
                    <ol style="margin-left: 20px; line-height: 2;">
                        <li><strong>Bước 1:</strong> Assign từng lỗ hổng cho developer phụ trách module đó</li>
                        <li><strong>Bước 2:</strong> Developer fix code theo hướng dẫn trong bảng trên</li>
                        <li><strong>Bước 3:</strong> Code review để đảm bảo fix đúng và không tạo lỗi mới</li>
                        <li><strong>Bước 4:</strong> Chạy lại security scan để verify đã fix</li>
                        <li><strong>Bước 5:</strong> Deploy lên production sau khi test kỹ</li>
                    </ol>
                </div>
            </div>

            <div class="section">
                <h2>Công Cụ & Tài Nguyên</h2>
                <div style="background: #f8f9fa; padding: 30px; border-radius: 10px;">
                    <h3 style="color: #667eea; margin-bottom: 20px;">🛠️ Công Cụ Đã Sử Dụng</h3>
                    <ul style="line-height: 2; font-size: 1.1em;">
                        <li><strong>Semgrep:</strong> SAST scanner - Phát hiện lỗ hổng trong source code</li>
                        <li><strong>Gitleaks:</strong> Secret scanner - Tìm hardcoded secrets</li>
                        <li><strong>DefectDojo:</strong> Vulnerability management platform</li>
                    </ul>
                    
                    <h3 style="color: #667eea; margin: 30px 0 20px 0;">📚 Tài Liệu Tham Khảo</h3>
                    <ul style="line-height: 2; font-size: 1.1em;">
                        <li><a href="https://owasp.org/www-project-top-ten/" target="_blank">OWASP Top 10</a> - Các lỗ hổng phổ biến nhất</li>
                        <li><a href="https://cheatsheetseries.owasp.org/" target="_blank">OWASP Cheat Sheet Series</a> - Hướng dẫn fix chi tiết</li>
                        <li><a href="https://cwe.mitre.org/" target="_blank">CWE</a> - Common Weakness Enumeration</li>
                    </ul>

                    <h3 style="color: #667eea; margin: 30px 0 20px 0;">🔄 Scan Lại Sau Khi Fix</h3>
                    <div class="code-example" style="background: #2d2d2d; color: #f8f8f2;">
# Chạy lại scan<br>
make scan<br>
<br>
# Import vào DefectDojo<br>
make import<br>
<br>
# Xem kết quả<br>
make open-defectdojo
                    </div>
                </div>
            </div>

            <div class="section">
                <h2>Liên Hệ & Hỗ Trợ</h2>
                <div style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 35px; border-radius: 15px;">
                    <p style="font-size: 1.2em; line-height: 2;">
                        <strong>Cần hỗ trợ fix lỗ hổng?</strong><br>
                        Truy cập DefectDojo để xem chi tiết từng lỗ hổng, assign cho team members, và track tiến độ khắc phục.
                    </p>
                    <p style="margin-top: 20px; font-size: 1.1em;">
                        🔗 <a href="http://localhost:8000" style="color: #ffd700; text-decoration: none; font-weight: bold;">Mở DefectDojo</a>
                    </p>
                </div>
            </div>
        </div>

        <div class="footer">
            <p style="font-size: 1.2em; margin-bottom: 10px;">Báo cáo được tạo tự động bởi Security Scanning Stack</p>
            <p>Xem chi tiết trong <a href="http://localhost:8000" target="_blank">DefectDojo</a></p>
            <p style="margin-top: 20px; opacity: 0.8;">© 2024 - Bảo mật là ưu tiên hàng đầu</p>
        </div>
    </div>
</body>
</html>
RECOMMENDATIONS

echo ""
echo "✅ Báo cáo đã được tạo: $OUTPUT_FILE"
echo ""
echo "Mở báo cáo:"
echo "  open $OUTPUT_FILE"
echo ""
echo "Hoặc chạy:"
echo "  make report-vi"
echo ""
