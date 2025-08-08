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

        stage('Run DAST Scan') {
            steps {
                sh 'chmod +x ./dast.sh'
                sh './dast.sh'
            }
        }

        stage('Generate ZAP Report') {
            steps {
                sh '''
                    mkdir -p zap_report
                    curl "http://127.0.0.1:8090/OTHER/core/other/htmlreport/?apikey=12345" \
                         -o "zap_report/zap_report.html"
                '''
            }
        }

        stage('Publish ZAP Report') {
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
