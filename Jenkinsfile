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

        stage('Publish Semgrep Report') {
            steps {
                sh '''
                    mkdir -p reports_html
                    echo "<html><body><pre>" > reports_html/semgrep_report.html
                    cat reports/semgrep_report.txt >> reports_html/semgrep_report.html
                    echo "</pre></body></html>" >> reports_html/semgrep_report.html
                '''
                publishHTML(target: [
                    reportDir: 'reports_html',
                    reportFiles: 'semgrep_report.html',
                    reportName: 'Semgrep Report',
                    allowMissing: false,
                    alwaysLinkToLastBuild: true,
                    keepAll: true
                ])
            }
        }

        stage('Run DAST (ZAP Script)') {
            steps {
                sh 'chmod +x ./dast.sh'
                sh 'sed -i "s/sudo //g" ./dast.sh'
                sh './dast.sh'
            }
        }

        stage('Publish ZAP Report') {
            steps {
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

