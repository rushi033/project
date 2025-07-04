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
                docker run --rm -v $(pwd):/src returntocorp/semgrep semgrep --config=semgrep/semgrep_rules.yml --output reports/semgrep_report.txt
                '''
            }
        }

        stage('Generate DOCX Report') {
    steps {
        sh '''
        mkdir -p reports
        chmod 777 reports
        pip install --user python-docx
        python3 report-generator/generate_report.py
       
    }
}


        stage('Archive Reports') {
            steps {
                archiveArtifacts artifacts: 'reports/*', fingerprint: true
            }
        }
    }
}
