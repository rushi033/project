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
        # Pull the ZAP Docker image if not already available locally
        echo "Pulling ZAP Docker image..."
        docker pull owasp/zap2docker-stable

        # Remove any existing ZAP container, if it exists
        docker rm -f zap || true
        
        # Start ZAP container in daemon mode
        echo "Starting ZAP container..."
        docker run -u root -d --name zap -p 8090:8090 -v $(pwd):/zap owasp/zap2docker-stable zap.sh -daemon -host 0.0.0.0 -port 8090
        
        # Sleep to ensure ZAP starts fully (you may adjust this based on your app's complexity)
        sleep 30
        
        # Define the URL to scan (GitHub Pages or live hosted app)
        def targetUrl="https://git@github.com:Onkar-kumbhar/exam-3025.git"

        # Run Spider scan to discover links and resources
        curl http://localhost:8090/JSON/spider/action/scan/?url=${targetUrl}
        
        # Run Active scan with recursion enabled
        curl http://localhost:8090/JSON/ascan/action/scan/?url=${targetUrl}&recurse=true
        
        # Wait for the scan to complete (you can increase this wait time if needed)
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

