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
                docker run --rm -v $(pwd):/src --user $(id -u):$(id -g) returntocorp/semgrep semgrep \
                --config=semgrep/semgrep_rules.yml \
                --output reports/semgrep_report.txt
                '''
            }
        }

        stage('Run Trivy Scan') {
            steps {
                sh '''
                mkdir -p reports
                docker pull aquasec/trivy:latest

                # Build or pull the image you want to scan (e.g. petclinic)
                # docker build -t petclinic .  # Uncomment if you want to build from Dockerfile

                docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
                    -v $(pwd)/reports:/root/reports --user $(id -u):$(id -g) \
                    aquasec/trivy image --format table --output /root/reports/trivy_report.txt petclinic
                '''
            }
        }

        stage('Generate DOCX Report') {
            steps {
                sh '''
                mkdir -p reports
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
}

