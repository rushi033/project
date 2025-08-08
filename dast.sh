#!/bin/bash
set -e

# Vars
HTML_DIR="$WORKSPACE/vuln-web"
ZAP_API_KEY="12345"

echo "📁 Setting up vulnerable HTML site..."
mkdir -p "$WORKSPACE/html"
cp -r "$HTML_DIR"/* "$WORKSPACE/html/"

echo "🔧 Starting Python HTTP server on port 8080..."
python3 -m http.server 8080 --directory "$WORKSPACE/html" &
sleep 5

echo "🌐 Local test site live at: http://localhost:8080"

echo "⏳ Starting ZAP daemon..."
zaproxy -daemon -config api.key=$ZAP_API_KEY -port 8090 -host 127.0.0.1 &
ZAP_PID=$!
sleep 30

echo "🔎 Running Spider..."
curl "http://127.0.0.1:8090/JSON/spider/action/scan/?apikey=$ZAP_API_KEY&url=http://localhost:8080&maxChildren=10"
while true; do
  spider_status=$(curl -s "http://127.0.0.1:8090/JSON/spider/view/status/?apikey=$ZAP_API_KEY" | grep -oP '\d+')
  echo "🕷️ Spider progress: $spider_status%"
  [ "$spider_status" -eq 100 ] && break
  sleep 5
done

echo "⚡ Running Active Scan..."
curl "http://127.0.0.1:8090/JSON/ascan/action/scan/?apikey=$ZAP_API_KEY&url=http://localhost:8080&recurse=true"
while true; do
  status=$(curl -s "http://127.0.0.1:8090/JSON/ascan/view/status/?apikey=$ZAP_API_KEY" | grep -oP '\d+')
  echo "🔍 Scan progress: $status%"
  [ "$status" -eq 100 ] && break
  sleep 5
done

echo "✅ DAST scan finished. Jenkins will now generate the report."

