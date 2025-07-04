pipeline {
    agent any

    environment {
        REPORTS_DIR = "reports"
        PETCLINIC_URL = "http://<machine-ip>/petclinic"  // Replace with actual IP or hostname
    }

    stages {
        stage('Clone Repo') {
            steps {
                git credentialsId: 'github-ssh-key', url: 'git@github.com:Onkar-kumbhar/exam-3025.git', branch: 'main'
            }
        }

        stage('Run Semgrep') {
            steps {
                sh '''
                mkdir -p ${REPORTS_DIR}
                docker run --rm -v $(pwd):/src returntocorp/semgrep semgrep --config=semgrep/semgrep_rules.yml --output ${REPORTS_DIR}/semgrep_report.txt
                '''
            }
        }

        stage('Run OWASP ZAP') {
            steps {
                script {
                    sh '''
                    mkdir -p ${REPORTS_DIR}

                    echo "Starting ZAP in background..."
                    /snap/bin/zaproxy -daemon -host 127.0.0.1 -port 8090 -config api.disablekey=true &

                    echo "Waiting for ZAP to be ready..."
                    until curl --silent --output /dev/null http://127.0.0.1:8090; do
                      sleep 5
                      echo "Still waiting for ZAP..."
                    done

                    echo "ZAP is ready. Starting Spider Scan..."
                    curl "http://127.0.0.1:8090/JSON/spider/action/scan/?url=${PETCLINIC_URL}"

                    echo "Starting Active Scan..."
                    curl "http://127.0.0.1:8090/JSON/ascan/action/scan/?url=${PETCLINIC_URL}&recurse=true"

                    echo "Waiting for Active Scan to complete..."
                    sleep 30  # Optional: implement proper polling here if needed

                    echo "Downloading ZAP HTML Report..."
                    curl "http://127.0.0.1:8090/OTHER/core/other/htmlreport/" -o ${REPORTS_DIR}/zapReport.html
                    '''
                }
            }
        }

        stage('Generate DOCX Report') {
            steps {
                sh '''
                pip install --user python-docx
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

    post {
        always {
            echo 'Pipeline execution finished.'
        }
        cleanup {
            sh 'pkill -f zaproxy || true'
        }
    }
}

