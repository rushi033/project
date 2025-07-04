pipeline {
    agent any

    stages {
        stage('Clone Repo') {
            steps {
                git credentialsId: 'github-ssh-key', url: 'git@github.com:Onkar-kumbhar/exam-3025.git', branch: 'main'
            }
        }

        stage('Run Semgrep') {
            steps {
                sh '''
                docker run --rm -v $(pwd):/src returntocorp/semgrep semgrep --config=semgrep/semgrep_rules.yml --output reports/semgrep_report.txt
                '''
            }
        }

        stage('Run ZAP Scan') {
            steps {
                sh '''#!/bin/bash
                # Remove any existing ZAP container
                docker rm -f zap || true
                
                # Start ZAP container in daemon mode
                echo "Starting ZAP container..."
                docker run -u root -d --name zap -p 8090:8090 -v $(pwd):/zap owasp/zap2docker-stable zap.sh -daemon -host 0.0.0.0 -port 8090
                
                # Sleep to ensure ZAP starts fully
                sleep 30
                
                # Define the URL for your GitHub repository's hosted application (or GitHub Pages)
                # Replace this URL with the actual hosted app URL (e.g., GitHub Pages, etc.)
                def targetUrl = "https://git@github.com:Onkar-kumbhar/exam-3025.git"

                # Run Spider scan to discover URLs and resources
                curl http://localhost:8090/JSON/spider/action/scan/?url=${targetUrl}
                
                # Run Active scan with recursion enabled
                curl http://localhost:8090/JSON/ascan/action/scan/?url=${targetUrl}&recurse=true
                
                # Wait for the scan to complete (can be adjusted based on your app's size and complexity)
                sleep 60
                
                # Generate HTML report for ZAP
                curl http://localhost:8090/OTHER/core/other/htmlreport/ > reports/zapReport.html
                '''
            }
        }

        stage('Generate DOCX Report') {
            steps {
                sh '''
                pip install python-docx
                python3 report-generator/generate_report.py
                '''
            }
        }

        stage('Archive Reports') {
            steps {
                archiveArtifacts artifacts: 'reports/*', fingerprint: true
            }
        }
    }
}
