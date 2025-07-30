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
        set -e

        # Clean reports folder if exists
        rm -rf reports
        mkdir reports

        # Remove existing container if any
        docker rm -f zap || true

        # Set the target app URL (must be running!)
        targetUrl="http://your-app:8080"  # CHANGE THIS!

        # Run ZAP in baseline scan mode
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
