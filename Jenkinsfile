pipeline {
    agent {
        kubernetes {
            label 'build-and-deploy-agent'
            containerTemplates([
                containerTemplate(
                    name: 'build-tools', 
                    image: 'google/cloud-sdk:478.0.0', 
                    command: 'cat', 
                    ttyEnabled: true,
                    resources: 'cpu: "250m", memory: "256Mi"' // Request resources for kubectl
                ),
                containerTemplate(
                    name: 'dind', 
                    image: 'docker:26.1.4-dind', 
                    privileged: true,
                    resources: 'cpu: "1000m", memory: "1024Mi"' // Request more resources for Docker builds
                )
            ])
            serviceAccount 'jenkins-agent-sa'
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
                    sh 'echo $DOCKERHUB_CREDENTIALS | docker login -u "dubithal" --password-stdin'
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
                    sh "kubectl apply -f k8s/flask-sa.yaml -f k8s/deployment.yaml -f k8s/hpa.yaml -f k8s/service.yaml --namespace default"
                    sh "kubectl apply -f k8s/vault-service-account.yaml"
                    sh "kubectl rollout restart deployment/flask-app --namespace default"
                    sh "kubectl rollout status deployment/flask-app --namespace default"
                    echo "Application deployed successfully!"
                }
            }
        }
    }
    
    post {
        always {
            // This command will run on the agent defined at the top level of the pipeline.
            container('dind') {
                sh 'docker logout'
            }
        }
    }
}
