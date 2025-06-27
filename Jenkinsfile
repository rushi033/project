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
        docker rm -f zap || true
        echo "Starting ZAP container..."
        docker run -u root -d --name zap -p 8090:8090 -v $(pwd):/zap ghcr.io/zaproxy/zaproxy zap-x.sh -daemon -host 0.0.0.0 -port 8090
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

