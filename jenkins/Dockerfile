FROM jenkins/jenkins:lts-jdk17

USER root

ARG DEBIAN_FRONTEND=noninteractive

ENV JAVA_OPTS="-Djenkins.install.runSetupWizard=false"

ARG KUBECTL_VERSION="1.30.2"
ARG HELM_VERSION="3.13.2"

RUN apt-get update && \
    apt-get install -y \
        docker.io \
        git \
        curl \
        python3-pip \
        groff \
        less \
        unzip && \
    curl -LO "https://dl.k8s.io/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl" && \
    install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl && \
    curl -fsSL "https://get.helm.sh/helm-v${HELM_VERSION}-linux-amd64.tar.gz" | tar -zx linux-amd64/helm --strip-components=1 && \
    install -o root -g root -m 0755 helm /usr/local/bin/helm && \
    usermod -aG docker jenkins && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* kubectl helm


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
