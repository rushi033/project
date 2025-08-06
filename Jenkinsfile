pipeline {
    agent any

    stages {
        stage('Checkout Code') {
            steps {
                git branch: 'main', url: 'https://github.com/rushi033/project.git'
            }
        }

        stage('Run Semgrep') {
            steps {
                sh '''
                    mkdir -p reports
                    docker run --rm \
                        -v "$PWD/app:/src" \
                        -v "$PWD/semgrep/semgrep_rules.yml:/semgrep_rules.yml" \
                        returntocorp/semgrep \
                        semgrep --config=/semgrep_rules.yml \
                                --output=/src/../reports/semgrep_report.txt
                '''
            }
        }

        stage('Display Semgrep Report') {
            steps {
                sh 'cat reports/semgrep_report.txt || echo "No Semgrep report found."'
            }
        }

        stage('Run DAST Scan (ZAP Baseline)') {
            steps {
                sh '''
                    mkdir -p zap_report
                    docker run --rm -u root \
                        -v $(pwd)/zap_report:/zap/wrk/:rw \
                        -t owasp/zap2docker-stable zap-baseline.py \
                        -t http://localhost \
                        -r zap_report.html
                '''
            }
        }

        stage('Archive and Publish ZAP Report') {
            steps {
                archiveArtifacts artifacts: 'zap_report/zap_report.html', fingerprint: true
                publishHTML(target: [
                    reportDir: 'zap_report',
                    reportFiles: 'zap_report.html',
                    reportName: 'OWASP ZAP Report',
                    allowMissing: false,
                    alwaysLinkToLastBuild: true,
                    keepAll: true
                ])
            }
        }
    }
}
