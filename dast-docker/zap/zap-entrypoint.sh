#!/bin/bash
set -e

# Variables (use environment vars if possible, fallback to defaults)
REPORT_DIR="/zap/wrk"
ZAP_API_KEY="${ZAP_API_KEY:-12345}"
TARGET_URL="${TARGET_URL:-http://web:8081}"

echo "🌐 Target site: $TARGET_URL"
echo "📁 Report dir: $REPORT_DIR"

# Wait for the target web server to be up
echo "⏳ Waiting for target web server..."
until curl -s "$TARGET_URL" > /dev/null; do
  echo "Waiting for $TARGET_URL ..."
  sleep 3
done

echo "⬇️ Starting ZAP daemon..."
# Start ZAP in daemon mode
zap.sh -daemon -host 0.0.0.0 -port 8090 -config api.key=$ZAP_API_KEY &
ZAP_PID=$!

echo "⏳ Waiting for ZAP to be ready..."
# Wait until ZAP API is available
until curl -s "http://localhost:8090" > /dev/null; do
  echo "Waiting for ZAP API..."
  sleep 5
done

echo "🚀 Starting Spider on $TARGET_URL..."
curl "http://localhost:8090/JSON/spider/action/scan/?apikey=$ZAP_API_KEY&url=$TARGET_URL&maxChildren=10"

while true; do
  spider_status=$(curl -s "http://localhost:8090/JSON/spider/view/status/?apikey=$ZAP_API_KEY" | grep -oP '\d+')
  echo "🕷️ Spider progress: $spider_status%"
  [ "$spider_status" -eq 100 ] && break
  sleep 5
done

echo "⚡ Starting Active Scan..."
curl "http://localhost:8090/JSON/ascan/action/scan/?apikey=$ZAP_API_KEY&url=$TARGET_URL&recurse=true"

while true; do
  status=$(curl -s "http://localhost:8090/JSON/ascan/view/status/?apikey=$ZAP_API_KEY" | grep -oP '\d+')
  echo "🔍 Scan progress: $status%"
  [ "$status" -eq 100 ] && break
  sleep 5
done

echo "📝 Generating report..."
curl "http://localhost:8090/OTHER/core/other/htmlreport/?apikey=$ZAP_API_KEY" -o "$REPORT_DIR/zap_report.html"

echo "✅ Report saved to: $REPORT_DIR/zap_report.html"

# Stop ZAP daemon
kill $ZAP_PID
