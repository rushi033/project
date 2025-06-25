from zapv2 import ZAPv2
import time

target = 'http://your-app-url'  # Replace dynamically or via ENV
apikey = 'changeme'
zap = ZAPv2(apikey=apikey)

zap.spider.scan(target)
time.sleep(5)
while int(zap.spider.status()) < 100:
    time.sleep(2)

zap.ascan.scan(target)
while int(zap.ascan.status()) < 100:
    time.sleep(5)

with open('reports/zap_report.html', 'w') as f:
    f.write(zap.core.htmlreport())

