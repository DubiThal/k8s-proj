pipeline {
    agent any
    
    environment {
        DOCKERHUB_CREDENTIALS = credentials('dockerhub-credentials')
        DOCKER_IMAGE = "dubithal/weather-app"
    }
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        
        stage('Build') {
            steps {
                dir('app') {
                    sh "docker build -t ${DOCKER_IMAGE}:${BUILD_NUMBER} ."
                    sh "docker tag ${DOCKER_IMAGE}:${BUILD_NUMBER} ${DOCKER_IMAGE}:latest"
                }
            }
        }
        
        stage('Login to DockerHub') {
            steps {
                sh 'echo $DOCKERHUB_CREDENTIALS_PSW | docker login -u $DOCKERHUB_CREDENTIALS_USR --password-stdin'
            }
        }
        
        stage('Push') {
            steps {
                sh "docker push ${DOCKER_IMAGE}:${BUILD_NUMBER}"
                sh "docker push ${DOCKER_IMAGE}:latest"
            }
        }

        stage('Deploy to K8s') {
            steps {
                echo "Deploying application to Kubernetes..."
                // Note: This assumes you have a 'deployment.yaml' in a 'k8s' directory.
                // It also assumes your Kubernetes context is correctly configured in the Jenkins environment.
                sh "kubectl apply -f k8s/"
                
                // Trigger a rollout of the new image version
                sh "kubectl set image deployment/weather-app-deployment weather-app=${DOCKER_IMAGE}:${BUILD_NUMBER}"
            }
        }
    }
    
    post {
        always {
            sh 'docker logout'
        }
    }
}
