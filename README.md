# 🌤️ K8S for Weather Forecast App – DevOps Project by Dubi Thal

## 🎯 Overview
This project is a Flask-based weather forecast web application, fully containerized using Docker. It features a complete CI/CD pipeline managed by Jenkins and is designed for eventual deployment to a Kubernetes cluster.
**Weather data is retrieved via the [OpenWeatherMap API](https://openweathermap.org/api).**

## ⚙️ Tools & Technologies
| Tool        | Purpose                         |
|-------------|----------------------------------|
| Flask       | Web framework for Python        |
| Docker      | Containerization                |
| Docker Compose | Local environment orchestration |
| Jenkins     | CI/CD server (running in Docker)|
| Git         | Version control                 |
| GitHub      | Source code hosting             |
| DockerHub   | Image repository                |
| Kubernetes  | Container Orchestration (Target) |
| NGINX       | Reverse proxy and HTTPS support |

## 🐳 Docker Setup
The project contains two Docker Compose setups:

- **app/** – Contains the Flask application and NGINX reverse proxy.
- **jenkins/** – Contains the Jenkins server, fully Dockerized with customized Dockerfile and plugins.

Jenkins is configured via Docker Compose and listens on port 8080.
NGINX serves as a secure reverse proxy for the Flask app (port 443) and handles HTTPS via Let's Encrypt certificates.

## 🔁 CI/CD Pipeline (Jenkins)
The Jenkins pipeline (defined in `Jenkinsfile`) performs the following:
- ✅ Clones the GitHub repository
- ✅ Builds the Docker image for the Flask app
- ✅ Pushes the tagged image to DockerHub
- 🔜 Deploys to Kubernetes using manifests from the `k8s/` directory

## 🚀 Additional Features Implemented
- ✅ HTTPS support via Let's Encrypt and NGINX
- ✅ Reverse proxy for Flask via NGINX (port 443)
- ✅ Split docker-compose files for Jenkins and Flask/NGINX
- ✅ CI/CD pipeline running inside Dockerized Jenkins
- ✅ Environment variables and `.env` support in Flask app
- ✅ K8s manifests prepared for deployment (Minikube testing in progress)

## 🗺️ Next Steps
- **Automated Testing**: Implement a `test` stage in the Jenkins pipeline using Pytest.
- **Kubernetes Deployment**: Finalize the `Deploy` stage in the Jenkinsfile to apply the `k8s/` manifests to a cluster.
- **Monitoring**: Integrate Prometheus & Grafana for application and cluster monitoring.
- **Secrets Management**: Implement a robust secrets solution like HashiCorp Vault or native Kubernetes Secrets.

### AI Assistance
This project was developed with occasional assistance from AI tools including ChatGPT, Claude, Gemini, and GitHub Copilot.
