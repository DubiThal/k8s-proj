pipeline {
    agent any
    
    environment {
        DOCKERHUB_CREDENTIALS = credentials('dockerhub-credentials')
        FLASK_IMAGE = "dubithal/k8s-weather-app"
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
                    sh "docker build -t ${FLASK_IMAGE}:${BUILD_NUMBER} ."
                    sh "docker tag ${FLASK_IMAGE}:${BUILD_NUMBER} ${FLASK_IMAGE}:latest"
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
                sh "docker push ${FLASK_IMAGE}:${BUILD_NUMBER}"
                sh "docker push ${FLASK_IMAGE}:latest"
            }
        }

        stage('Deploy to K8s') {
            steps {
                echo "Deploying application to Kubernetes..."
                sh "kubectl apply -f k8s/"
                sh "kubectl set image deployment/k8s-weather-app-deployment weather-app=${FLASK_IMAGE}:${BUILD_NUMBER}"
            }
        }
    }
    
    post {
        always {
            sh 'docker logout'
        }
    }
}
