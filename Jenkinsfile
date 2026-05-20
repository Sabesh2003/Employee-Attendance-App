pipeline {
    agent any
    environment {
        DOCKER_IMAGE = "sabesh2003/attendance-app"
        DOCKER_TAG   = "${BUILD_NUMBER}"
    }
    stages {
        stage('Checkout') {
            steps {
                echo '📥 Pulling code from GitHub...'
                checkout scm
            }
        }
        stage('Build Docker Image') {
            steps {
                echo '🐳 Building Docker image...'
                sh "docker build -t ${DOCKER_IMAGE}:${DOCKER_TAG} ."
                sh "docker tag ${DOCKER_IMAGE}:${DOCKER_TAG} ${DOCKER_IMAGE}:latest"
            }
        }
        stage('Push to Docker Hub') {
            steps {
                echo 'Pushing to Docker Hub...'
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub-creds',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    sh '''
                        echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                        docker push sabesh2003/attendance-app:latest
                    '''
                }
            }
        }
        stage('Deploy to Kubernetes') {
            steps {
                echo '☸️ Deploying to Kubernetes...'
                sh """
                    export KUBECONFIG=/var/jenkins_home/.kube/config
                    kubectl apply -f k8s/deployment.yaml
                    kubectl apply -f k8s/service.yaml
                    kubectl set image deployment/attendance-app attendance-app=${DOCKER_IMAGE}:latest
                    kubectl rollout status deployment/attendance-app --timeout=120s
                """
            }
        }
    }
    post {
        success { echo '✅ Pipeline completed!' }
        failure { echo '❌ Pipeline failed!' }
    }
}