#!/bin/bash
set -e
sudo apt update
sudo apt install openjdk-17-jre -y
sudo apt install curl -y

# Vars
REPORT_DIR="/home/osboxes/new/DevSecOps/zap_report"
HTML_DIR="/home/osboxes/new/DevSecOps/vuln-web"

ZAP_API_KEY="12345"

echo "📦 Installing dependencies..."
sudo apt update
sudo apt install -y apache2 unzip wget default-jre

echo "📁 Setting up vulnerable HTML site..."
sudo mkdir -p /var/www/html
sudo cp -r "$HTML_DIR"/* /var/www/html/

echo "🔧 Starting Apache2..."
sudo systemctl enable apache2
sudo systemctl restart apache2

echo "🌐 Your local site should be live at: http://localhost"

echo "⬇️ Downloading latest OWASP ZAP..."

# Get the latest ZAP download link dynamically
LATEST_ZAP_URL=$(wget -qO- https://api.github.com/repos/zaproxy/zaproxy/releases/latest | grep "browser_download_url.*unix\.sh" | cut -d '"' -f 4)

if [ -z "$LATEST_ZAP_URL" ]; then
    echo "❌ Failed to fetch latest ZAP download URL."
    exit 1
fi

cd ~
wget "$LATEST_ZAP_URL" -O zap.sh
chmod +x zap.sh
./zap.sh -q -dir "$HOME/ZAP"

echo "⏳ Waiting for ZAP startup in background..."

"$HOME/ZAP/zap.sh" -daemon -config api.key=$ZAP_API_KEY -port 8090 -host 127.0.0.1 &
sleep 30

echo "🚀 Starting DAST scan on http://localhost"
mkdir -p "$REPORT_DIR"

echo "🔎 Starting Spider to build site tree..."
curl "http://127.0.0.1:8090/JSON/spider/action/scan/?apikey=$ZAP_API_KEY&url=http://localhost&maxChildren=10"

# Wait for spider to finish
while true; do
  spider_status=$(curl -s "http://127.0.0.1:8090/JSON/spider/view/status/?apikey=$ZAP_API_KEY" | grep -oP '\d+')
  echo "🕷️ Spider progress: $spider_status%"
  [ "$spider_status" -eq 100 ] && break
  sleep 5
done

echo "⚡ Starting Active Scan..."
curl "http://127.0.0.1:8090/JSON/ascan/action/scan/?apikey=$ZAP_API_KEY&url=http://localhost&recurse=true"


# Wait for scan to finish
while true; do
  status=$(curl -s "http://127.0.0.1:8090/JSON/ascan/view/status/?apikey=$ZAP_API_KEY" | grep -oP '\d+')
  echo "🔍 Scan progress: $status%"
  [ "$status" -eq 100 ] && break
  sleep 5
done

echo "📝 Generating report..."
curl "http://127.0.0.1:8090/OTHER/core/other/htmlreport/?apikey=$ZAP_API_KEY" -o "$REPORT_DIR/zap_report.html"

echo "✅ Report saved to: $REPORT_DIR/zap_report.html"
