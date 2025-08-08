pipeline {
    agent any

    triggers {
        githubPush()
    }

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

        stage('Stop ZAP') {
            steps {
                sh 'curl "http://127.0.0.1:8090/JSON/core/action/shutdown/?apikey=12345" || true'
            }
        }
    }

    post {
        success {
            emailext(
                to: 'rushiambalkar2@gmail.com',
                subject: "✅ Jenkins Build Successful: ${env.JOB_NAME} #${env.BUILD_NUMBER}",
                body: """Good news! 🎉
                
                The pipeline completed successfully.

                - Job: ${env.JOB_NAME}
                - Build Number: ${env.BUILD_NUMBER}
                - Build URL: ${env.BUILD_URL}
                """
            )
        }
        failure {
            emailext(
                to: 'rushiambalkar2@gmail.com',
                subject: "❌ Jenkins Build Failed: ${env.JOB_NAME} #${env.BUILD_NUMBER}",
                body: """Uh-oh! 🚨
                
                The pipeline failed.

                - Job: ${env.JOB_NAME}
                - Build Number: ${env.BUILD_NUMBER}
                - Build URL: ${env.BUILD_URL}
                Please check the console output for details.
                """
            )
        }
    }
}
