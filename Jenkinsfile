pipeline {
    agent {
        kubernetes {
            label 'build-and-deploy-agent'
            containerTemplates([
                containerTemplate(name: 'build-tools', image: 'google/cloud-sdk:478.0.0', command: 'cat', ttyEnabled: true),
                containerTemplate(name: 'dind', image: 'docker:26.1.4-dind', privileged: true)
            ])
        }
    }
    
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
                container('dind') {
                    dir('app') {
                        sh "docker build -t ${FLASK_IMAGE}:${BUILD_NUMBER} ."
                        sh "docker tag ${FLASK_IMAGE}:${BUILD_NUMBER} ${FLASK_IMAGE}:latest"
                    }
                }
            }
        }
        
        stage('Login to DockerHub') {
            steps {
                container('dind') {
                    sh 'echo $DOCKERHUB_CREDENTIALS_PSW | docker login -u $DOCKERHUB_CREDENTIALS_USR --password-stdin'
                }
            }
        }
        
        stage('Push') {
            steps {
                container('dind') {
                    sh "docker push ${FLASK_IMAGE}:${BUILD_NUMBER}"
                    sh "docker push ${FLASK_IMAGE}:latest"
                }
            }
        }

        stage('Deploy to K8s') {
            steps {
                container('build-tools') {
                    echo "Deploying application to Kubernetes..."
                    sh "kubectl apply -f k8s/"
                    sh "kubectl rollout restart deployment/k8s-weather-app-deployment"
                    sh "kubectl rollout status deployment/k8s-weather-app-deployment"
                    echo "Application deployed successfully!"
                }
            }
        }
    }
    
    post {
        always {
            container('dind') {
                sh 'docker logout'
            }
        }
    }
}
