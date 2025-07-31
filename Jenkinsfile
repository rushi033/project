pipeline {
    agent any

    stages {
        stage('Checkout Code') {
            steps {
                git 'https://github.com/Onkar-kumbhar/DevSecOps.git'
            }
        }

        stage('Run Semgrep Scan') {
            steps {
                sh '''
                mkdir -p reports
                docker run --rm \
                  -v "$PWD/app":/src \
                  -v "$PWD/semgrep_rules.yml":/rules/semgrep_rules.yml \
                  returntocorp/semgrep \
                  semgrep --config=/rules/semgrep_rules.yml \
                          --output=/src/../reports/semgrep_report.txt
                '''
            }
        }

        stage('Display Semgrep Report') {
            steps {
                sh 'cat reports/semgrep_report.txt || echo "No report found."'
            }
        }
    }
}
