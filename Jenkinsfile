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
                rm -f reports/semgrep_report.txt

                docker run --rm \
                  -u $(id -u):$(id -g) \
                  -e HOME=/tmp \
                  -v $(pwd):/src \
                  returntocorp/semgrep \
                  sh -c "semgrep --config=/src/semgrep/semgrep_rules.yml --output=/tmp/semgrep_report.txt && cp /tmp/semgrep_report.txt /src/reports/"
                '''
            }
        }

        stage('Generate DOCX Report') {
            steps {
                sh '''
                # Check if report exists
                if [ ! -f reports/semgrep_report.txt ]; then
                  echo "Semgrep report not found!"
                  exit 1
                fi

                # Optional: create virtualenv
                python3 -m venv venv
                . venv/bin/activate

                # Install docx package
                pip install --upgrade pip
                pip install python-docx

                # Run the report generator
                python3 report-generator/generate_report.py
                '''
            }
        }

        stage('Archive Reports') {
            steps {
                archiveArtifacts artifacts: 'reports/*', fingerprint: true
            }
        }
    }
}

