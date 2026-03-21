pipeline {
    agent any

    environment {
        GHCR_IMAGE = "ghcr.io/wanniarachchichaluka/flask-cicd-app"
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Set Variables') {
            steps {
                script {
                    env.GIT_SHA = sh(script: 'git rev-parse --short HEAD', returnStdout: true).trim()
                }
            }
        }

        stage('Install Dependencies') {
            steps {
                sh '''
                    python3 -m venv venv
                    . venv/bin/activate
                    pip install -r requirements.txt
                '''
            }
        }

        stage('Test') {
            steps {
                sh '''
                    . venv/bin/activate
                    python3 -m pytest test_app.py -v
                '''
            }
        }

        stage('Lint') {
            steps {
                sh '''
                    . venv/bin/activate
                    python3 -m flake8 app.py --max-line-length=88
                '''
            }
        }

        stage('Build Docker Image') {
            steps {
                sh """
                    docker build -t ${GHCR_IMAGE}:${GIT_SHA} .
                """
            }
        }

        stage('Push to GHCR') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'ghcr-credentials',
                    usernameVariable: 'GHCR_USER',
                    passwordVariable: 'GHCR_TOKEN'
                )]) {
                    sh """
                        echo \$GHCR_TOKEN | docker login ghcr.io -u \$GHCR_USER --password-stdin
                        docker push ${GHCR_IMAGE}:${GIT_SHA}
                    """
                }
            }
        }

        stage('Deploy to Staging') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'ghcr-credentials',
                    usernameVariable: 'GHCR_USER',
                    passwordVariable: 'GHCR_TOKEN'
                )]) {
                    sh """
                        echo \$GHCR_TOKEN | docker login ghcr.io -u \$GHCR_USER --password-stdin
                        docker pull ${GHCR_IMAGE}:${GIT_SHA}
                        docker stop flask-staging || true
                        docker rm flask-staging || true
                        docker run -d \
                            --name flask-staging \
                            -p 5000:5000 \
                            --restart unless-stopped \
                            ${GHCR_IMAGE}:${GIT_SHA}
                    """
                }
            }
        }

        stage('Smoke Test') {
            steps {
                sh '''
                    sleep 5
                    curl -f http://localhost:5000/health
                '''
            }
        }

    }

    post {
        success {
            echo 'Pipeline ran successfully'
        }
        failure {
            echo 'Pipeline failed. Check the log'
        }
    }
}
