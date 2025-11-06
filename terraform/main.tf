provider "helm" {
  kubernetes = {
    config_path = "~/.kube/config"
  }
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"
  }
}

resource "kubernetes_namespace" "vault" {
  metadata {
    name = "vault"
  }
}

resource "kubernetes_namespace" "jenkins" {
  metadata {
    name = "jenkins"
  }
}

resource "kubernetes_namespace" "local_path_storage" {
  metadata {
    name = "local-path-storage"
  }
}

 resource "helm_release" "prometheus" {
   name             = "prometheus"
   repository       = "https://prometheus-community.github.io/helm-charts"
   chart            = "prometheus"
   namespace        = kubernetes_namespace.monitoring.metadata[0].name
   create_namespace = false
   values           = [file("${path.module}/prometheus-values.yaml")]
   depends_on = [
     kubernetes_namespace.monitoring,
     kubernetes_manifest.local_path_provisioner
   ]
 }

resource "helm_release" "grafana" {
  name       = "grafana"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "grafana"
  namespace  = kubernetes_namespace.monitoring.metadata[0].name
  values     = [file("${path.module}/grafana-values.yaml")]
  depends_on = [
    kubernetes_namespace.monitoring,
    kubernetes_manifest.local_path_provisioner
  ]
}

resource "helm_release" "vault" {
  name       = "vault"
  repository = "https://helm.releases.hashicorp.com"
  chart      = "vault"
  namespace  = kubernetes_namespace.vault.metadata[0].name
  values     = [file("${path.module}/vault-values.yaml")]
  depends_on = [
    kubernetes_namespace.vault,
    kubernetes_manifest.local_path_provisioner
  ]
}

locals {
  # Split the multi-document YAML into a list of individual YAML document strings
  local_path_manifest_strings = split("---", data.http.local_path_storage.response_body)
}

resource "kubernetes_manifest" "local_path_provisioner" {
  # Iterate over the list of YAML strings, filtering out any empty ones
  for_each = {
    for i, s in local.local_path_manifest_strings : i => s
    if trimspace(s) != "" && !startswith(yamldecode(s).kind, "Namespace")
  }
  manifest = yamldecode(each.value)
  depends_on = [
    kubernetes_namespace.local_path_storage
  ]
}

data "http" "local_path_storage" {
  url = "https://raw.githubusercontent.com/rancher/local-path-provisioner/v0.0.26/deploy/local-path-storage.yaml"
  # Optional: Add a checksum to ensure the file integrity
  # request_checksum = "sha256:..."
}

resource "helm_release" "jenkins" {
  name       = "jenkins"
  repository = "https://charts.jenkins.io"
  chart      = "jenkins"
  namespace  = kubernetes_namespace.jenkins.metadata[0].name
  values     = [file("${path.module}/jenkins-values.yaml")]
  timeout    = 300
  depends_on = [
    kubernetes_namespace.jenkins,
    kubernetes_manifest.local_path_provisioner
  ]
}
