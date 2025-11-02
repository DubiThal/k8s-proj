FROM jenkins/jenkins:lts

USER root

ARG DEBIAN_FRONTEND=noninteractive

# Define versions for tools to ensure consistent builds
ARG KUBECTL_VERSION="1.28.3"
ARG HELM_VERSION="3.13.2"

RUN apt-get update && \
    apt-get install -y \
        docker.io \
        git \
        curl \
        sudo \
        openjdk-17-jdk \
        python3 \
        python3-pip \
        groff \
        less \
        unzip && \
    # Install AWS CLI (useful for authenticating with EKS)
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    ./aws/install && \
    # Install kubectl
    curl -LO "https://dl.k8s.io/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl" && \
    install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl && \
    # Install Helm
    curl -fsSL "https://get.helm.sh/helm-v${HELM_VERSION}-linux-amd64.tar.gz" | tar -zx && \
    mv linux-amd64/helm /usr/local/bin/helm && \
    # Clean up downloaded files in the same layer to reduce image size
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* aws awscliv2.zip kubectl linux-amd64

RUN jenkins-plugin-cli --plugins \
    git \
    pipeline-stage-view \
    docker-workflow \
    github \
    credentials \
    workflow-aggregator \
    blueocean \
    configuration-as-code \
    github-branch-source \
    git-client \
    git-server \
    multibranch-scan-webhook-trigger

RUN usermod -aG docker jenkins

USER jenkins

ENV JENKINS_OPTS="--httpPort=8080"
ENV JENKINS_SLAVE_AGENT_PORT=50000

CMD ["/usr/local/bin/jenkins.sh"]
