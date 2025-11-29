# 🌤️ K8S for Weather Forecast App – DevOps Project by Dubi Thal

## 🎯 Overview
This project is a Flask-based weather forecast web application, fully containerized using Docker and deployed to Kubernetes. It features a complete CI/CD pipeline managed by Jenkins that automates building, testing, and deploying the application, with secrets securely managed by HashiCorp Vault.
**Weather data is retrieved via the [OpenWeatherMap API](https://openweathermap.org/api).**

## ⚙️ Tools & Technologies
| Tool        | Purpose                         |
|-------------|----------------------------------|
| Flask       | Web framework for Python        |
| Pytest      | Automated testing               |
| Docker      | Containerization                |
| Docker Compose | Local environment orchestration |
| Jenkins     | CI/CD server (running in Docker)|
| Minikube    | Local Kubernetes development    |
| HashiCorp Vault | Secrets Management              |
| Git         | Version control                 |
| GitHub      | Source code hosting             |
| DockerHub   | Image repository                |
| Kubernetes  | Container Orchestration (Target) |

## 🐳 Docker Setup
The project contains two Docker Compose setups:

- **app/** – Contains the Flask application
- **jenkins/** – Contains the Jenkins server, fully Dockerized with customized Dockerfile and plugins.

Jenkins is configured via Docker Compose and listens on port 8080.

## 📂 Project Structure
```
├── app/            # Flask application source code and Dockerfile
├── jenkins/        # Docker Compose and configuration for the Jenkins server
├── k8s/            # Kubernetes manifests (Deployment, Service, SA, HPA)
├── terraform/      # Terraform code to provision infrastructure (Helm charts for Jenkins, Vault, etc.)
├── Jenkinsfile.groovy # Declarative pipeline definition for the CI/CD process
└── README.md
```

##  CI/CD Pipeline (Jenkins)
The Jenkins pipeline (defined in `Jenkinsfile`) performs the following:
- ✅ Clones the GitHub repository
- ✅ Builds the Docker image for the Flask app
- ✅ Pushes the version-tagged image to DockerHub.
- ✅ Deploys the application to a Kubernetes cluster by applying the manifests from the `k8s/` directory.
- ✅ Performs a rolling restart of the deployment to ensure the new image is used.

## 🔐 Secure Secrets Management with HashiCorp Vault
This project implements a secure, end-to-end workflow for managing the OpenWeatherMap API key, ensuring no secrets are ever hard-coded in the repository or Docker images.

The workflow is as follows:
1.  **Vault Kubernetes Authentication**: The Kubernetes Auth Method is enabled in Vault, allowing pods to authenticate using their native Kubernetes Service Account tokens.
2.  **Policies & Roles**: A specific Vault policy (`flask-app-policy`) is created that grants read-only access to the secret path. A Vault role (`flask-app-role`) binds this policy to the application's Kubernetes Service Account (`flask-service-account`).
3.  **Vault Agent Injection**: The Flask application's `Deployment` is annotated to enable the Vault Agent Injector. This sidecar pattern automatically handles authentication and secret retrieval.
4.  **Secret Rendering**: A Vault Agent template is used to read the `api-key` from Vault and write it to a file (`/vault/secrets/api-key`) inside the pod.
5.  **Application Startup**: The container's entrypoint command sources this file, securely exporting the `WEATHER_API_KEY` as an environment variable just before the Python application starts.

## 📊 Monitoring with Prometheus & Grafana
The project is configured for monitoring using the standard Prometheus and Grafana stack deployed via Helm.
- **Prometheus**: Scrapes metrics from the Kubernetes cluster and the application.
- **Grafana**: Provides a visualization dashboard for viewing metrics collected by Prometheus, allowing for real-time monitoring of application performance and cluster health.

## 🚀 How to Run
1.  **Start Kubernetes**: Launch a local Kubernetes cluster (e.g., `minikube start`).
2.  **Provision Infrastructure**: Navigate to the `terraform/` directory and run `terraform init` followed by `terraform apply`. This will deploy Jenkins, Vault, Prometheus, and Grafana using Helm.
3.  **Initialize Vault**: Run the `terraform/init-unseal.sh` script to initialize and unseal Vault. Store the root token securely.
4.  **Configure Jenkins**: Set up the pipeline job in Jenkins, pointing to the `Jenkinsfile.groovy` in this repository. Add necessary credentials (DockerHub, GitHub).
5.  **Store the Secret**: Manually write the `WEATHER_API_KEY` into Vault at the `secret/weather-app/config` path.
6.  **Run the Pipeline**: Trigger the Jenkins pipeline. It will build the app, push the image, and deploy it to Kubernetes.
7.  **Access the App**: Use `minikube service flask-service` to open the application in your browser.

## 🗺️ Next Steps
- **Automated Testing**: Enhance the Jenkins pipeline by adding a dedicated `Test` stage that runs `pytest` against the application code before the Docker image is built.
- **GitOps**: Transition the deployment process to a GitOps model using a tool like Argo CD.
- **Cloud Deployment**: Migrate the deployment from a local Minikube cluster to a managed Kubernetes service (EKS, GKE, AKS).

### AI Assistance
This project was developed with occasional assistance from AI tools including ChatGPT, Claude, Gemini, and GitHub Copilot.
