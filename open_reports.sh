#!/bin/bash

# Paths to your local reports
SEMGRREP_REPORT="$HOME/new/DevSecOps/reports/semgrep_report.txt"
ZAP_REPORT="$HOME/new/DevSecOps/zap_report/zap_report.html"

# Open Semgrep report (text viewer or browser depending on default)
if [ -f "$SEMGRREP_REPORT" ]; then
    echo "Opening Semgrep report..."
    xdg-open "$SEMGRREP_REPORT" >/dev/null 2>&1 &
else
    echo "❌ Semgrep report not found at: $SEMGRREP_REPORT"
fi

# Open ZAP report (browser)
if [ -f "$ZAP_REPORT" ]; then
    echo "Opening ZAP report..."
    xdg-open "$ZAP_REPORT" >/dev/null 2>&1 &
else
    echo "❌ ZAP report not found at: $ZAP_REPORT"
fi
