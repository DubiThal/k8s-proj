pipeline {
    agent {
        kubernetes {
            label 'build-and-deploy-agent'
            containerTemplates([
                containerTemplate(name: 'build-tools', image: 'carlossg/docker-access-gcloud-kubectl:latest', command: 'cat', ttyEnabled: true),
                containerTemplate(name: 'dind', image: 'docker:20.10.7-dind', privileged: true)
            ])
        }
    }
    
    environment {
        DOCKER_HOST = 'tcp://localhost:2375'
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
                container('build-tools') {
                    dir('app') {
                        sh "docker build -t ${FLASK_IMAGE}:${BUILD_NUMBER} ."
                        sh "docker tag ${FLASK_IMAGE}:${BUILD_NUMBER} ${FLASK_IMAGE}:latest"
                    }
                }
            }
        }
        
        stage('Login to DockerHub') {
            steps {
                container('build-tools') {
                    sh 'echo $DOCKERHUB_CREDENTIALS_PSW | docker login -u $DOCKERHUB_CREDENTIALS_USR --password-stdin'
                }
            }
        }
        
        stage('Push') {
            steps {
                container('build-tools') {
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
            container('build-tools') {
                sh 'docker logout'
            }
        }
    }
}
