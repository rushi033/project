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

                # Run Semgrep and output directly into mounted folder
                docker run --rm \
                    -v $(pwd):/src \
                    -w /src \
                    returntocorp/semgrep \
                    semgrep --config=semgrep/semgrep_rules.yml \
                            --output=reports/semgrep_report.txt \
                            --force-color
                '''
            }
        }
    }
}
