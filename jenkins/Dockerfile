FROM jenkins/jenkins:lts-jdk17

USER root

ARG DEBIAN_FRONTEND=noninteractive

# Define versions for tools to ensure consistent builds
ARG KUBECTL_VERSION="1.30.2"
ARG HELM_VERSION="3.13.2"

RUN apt-get update && \
    apt-get install -y \
        docker.io \
        git \
        curl \
        sudo \
        python3-pip \
        groff \
        less \
        unzip && \
    # Install kubectl
    curl -LO "https://dl.k8s.io/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl" && \
    install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl && \
    # Install Helm
    curl -fsSL "https://get.helm.sh/helm-v${HELM_VERSION}-linux-amd64.tar.gz" | tar -zx && \
    mv linux-amd64/helm /usr/local/bin/helm && \
    # Add jenkins user to the docker group
    usermod -aG docker jenkins && \
    # Clean up downloaded files in the same layer to reduce image size
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* aws awscliv2.zip kubectl linux-amd64

# Install Jenkins plugins. Merged from multiple sections for clarity.
# The 'plugins.txt' approach is good, but since you had a separate RUN command,
# let's consolidate them. You can move these to a plugins.txt file later if you wish.
RUN jenkins-plugin-cli --plugins \
    git \
    pipeline-stage-view \
    docker-workflow \
    github \
    credentials \
    blueocean \
    configuration-as-code \
    github-branch-source \
    kubernetes \
    workflow-aggregator

USER jenkins
