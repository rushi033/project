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

        # Run semgrep and write directly to mounted host volume
        docker run --rm \
            -u 0:0 \
            -v $(pwd):/src \
            -w /src \
            returntocorp/semgrep \
            semgrep --config=semgrep/semgrep_rules.yml \
                    --output=reports/semgrep_report.txt \
                    --force-color
        '''
    }
}

