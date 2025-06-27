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
        sh '''
            # Debug: Check if the scan script exists
            echo "Checking zap-scan script existence..."
            ls -l zap-scanner/
            test -f zap-scanner/zap_scan.py || (echo "zap_scan.py not found!" && exit 1)

            # Clean any previous container
            docker rm -f zap || true

            # Start the ZAP container in daemon mode
            echo "Starting ZAP container..."
            docker run -u root -d --name zap -p 8090:8090 -v $(pwd):/zap owasp/zap2docker-stable zap.sh -daemon -host 0.0.0.0 -port 8090

            echo "Waiting for ZAP to fully start..."
            sleep 20

            # Copy the script into the container
            echo "Copying zap_scan.py into container..."
            docker cp zap-scanner/zap_scan.py zap:/zap/

            # Run the script inside the container
            echo "Running ZAP scan..."
            docker exec zap python3 /zap/zap_scan.py
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

