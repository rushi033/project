pipeline {
    agent any

       stages {
        stage('Checkout Code') {
            steps {
                git branch: 'main', url: 'https://github.com/Onkar-kumbhar/DevSecOps.git'
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
                sh 'cat reports/semgrep_report.txt || echo "No report found."'
            }
        }
    }
}
