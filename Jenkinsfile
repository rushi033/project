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

                # Run Semgrep and always overwrite the report
                docker run --rm \
                    -u 0:0 \
                    -e HOME=/tmp \
                    -v $(pwd):/src \
                    returntocorp/semgrep \
                    sh -c "semgrep --config=/src/semgrep/semgrep_rules.yml --output=/src/reports/semgrep_report.txt --force-color"
                '''
            }
        }
    }
}
