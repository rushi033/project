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
        mkdir -p reports
        docker run --rm \
          -u $(id -u):$(id -g) \
          -e HOME=/tmp \
          -v $(pwd):/src \
          returntocorp/semgrep \
          semgrep --config=semgrep/semgrep_rules.yml --output /src/reports/semgrep_report.txt
        '''
    }
}



    stage('Run ZAP Scan') {
        steps {
        sh '''#!/bin/bash
        set -e

        # Create reports directory if it doesn't exist
        mkdir -p reports

        # Only remove the ZAP report file — do NOT remove the whole folder!
        rm -f reports/zapReport.html || true

        # Remove any running ZAP container
        docker rm -f zap || true

        # Set the target application URL (must be running)
        targetUrl="http://your-app:8080"  # CHANGE THIS

        # Run ZAP baseline scan
        docker run --rm \
          -v $(pwd)/reports:/zap/reports \
          owasp/zap2docker-stable zap-baseline.py \
          -t $targetUrl -r zapReport.html
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
