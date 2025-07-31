pipeline {
    agent any

    stages {
        stage('Clone Repo') {
            steps {
                git credentialsId: 'github-ssh-key', url: 'git@github.com:Onkar-kumbhar/exam-3025.git', branch: 'main'
            }
        }

        stage('Run Semgrep on Local Project') {
            steps {
                dir('pro1') { // assuming you copy pro1 into your workspace or symlink it
                    sh '''
                    mkdir -p ../reports
                    rm -f ../reports/semgrep_report.txt || true

                    docker run --rm \
                        -v $(pwd):/src \
                        -v $(pwd)/../semgrep:/rules \
                        returntocorp/semgrep \
                        semgrep --config=/rules/semgrep_rules.yml \
                                --output=/src/../reports/semgrep_report.txt
                    '''
                }
            }
        }

        stage('Archive Reports') {
            steps {
                archiveArtifacts artifacts: 'reports/*', fingerprint: true
            }
        }
    }
}
