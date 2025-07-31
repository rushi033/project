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

                # Take ownership to avoid permission issues
                sudo chown -R $(id -u):$(id -g) reports || true

                rm -f reports/semgrep_report.txt || true

                docker run --rm \
                    -u $(id -u):$(id -g) \
                    -e HOME=/tmp \
                    -v $(pwd):/src \
                    returntocorp/semgrep \
                    sh -c "semgrep --config=/src/semgrep/semgrep_rules.yml --output=/tmp/semgrep_report.txt && cp /tmp/semgrep_report.txt /src/reports/"
                '''
            }
        }
    }
}

