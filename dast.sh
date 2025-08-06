#!/bin/bash
set -e

# Vars
REPORT_DIR="$WORKSPACE/zap_report"
HTML_DIR="$WORKSPACE/vuln-web"
ZAP_API_KEY="12345"

echo "📁 Setting up vulnerable HTML site..."
mkdir -p "$HOME/html"
sudo cp -r "$HTML_DIR"/* "$HOME/html/"
sudo cp -r "$HOME/html/"/* /var/www/html
python3 -m http.server 80 --directory "$HOME/html" &

echo "🔧 Starting Apache2..."
echo "Starting Python HTTP server on port 8080"
python3 -m http.server 8081 --directory "$HOME/html" &
sleep 5

echo "🌐 Your local site should be live at: http://localhost"

# Removed ZAP download/install

echo "⏳ Starting ZAP daemon..."
zaproxy -daemon -config api.key=$ZAP_API_KEY -port 8090 -host 127.0.0.1 &
sleep 30

echo "🚀 Starting DAST scan on http://localhost"
mkdir -p "$REPORT_DIR"

# ... rest unchanged ...


echo "🔎 Starting Spider to build site tree..."
curl "http://127.0.0.1:8090/JSON/spider/action/scan/?apikey=$ZAP_API_KEY&url=http://localhost&maxChildren=10"

while true; do
  spider_status=$(curl -s "http://127.0.0.1:8090/JSON/spider/view/status/?apikey=$ZAP_API_KEY" | grep -oP '\d+')
  echo "🕷️ Spider progress: $spider_status%"
  [ "$spider_status" -eq 100 ] && break
  sleep 5
done

echo "⚡ Starting Active Scan..."
curl "http://127.0.0.1:8090/JSON/ascan/action/scan/?apikey=$ZAP_API_KEY&url=http://localhost&recurse=true"

while true; do
  status=$(curl -s "http://127.0.0.1:8090/JSON/ascan/view/status/?apikey=$ZAP_API_KEY" | grep -oP '\d+')
  echo "🔍 Scan progress: $status%"
  [ "$status" -eq 100 ] && break
  sleep 5
done

echo "📝 Generating report..."
curl "http://127.0.0.1:8090/OTHER/core/other/htmlreport/?apikey=$ZAP_API_KEY" -o "$REPORT_DIR/zap_report.html"

echo "✅ Report saved to: $REPORT_DIR/zap_report.html"
