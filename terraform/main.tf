provider "helm" {
  kubernetes {
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

# resource "helm_release" "prometheus" {
#   name             = "prometheus"
#   repository       = "https://prometheus-community.github.io/helm-charts"
#   chart            = "prometheus"
#   namespace        = kubernetes_namespace.monitoring.metadata[0].name
#   create_namespace = false
#   values           = [file("${path.module}/prometheus-values.yaml")]
#   timeout    = 90
#   depends_on       = [kubernetes_namespace.monitoring]
# }

#resource "helm_release" "grafana" {
#  name       = "grafana"
#  repository = "https://grafana.github.io/helm-charts"
#  chart      = "grafana"
#  namespace  = kubernetes_namespace.monitoring.metadata[0].name
#  values     = [file("${path.module}/grafana-values.yaml")]
#  depends_on = [kubernetes_namespace.monitoring]
#}

resource "helm_release" "vault" {
  name       = "vault"
  repository = "https://helm.releases.hashicorp.com"
  chart      = "vault"
  namespace  = kubernetes_namespace.vault.metadata[0].name
  values     = [file("${path.module}/vault-values.yaml")]
  depends_on = [kubernetes_namespace.vault]
}

resource "helm_release" "jenkins" {
  name       = "jenkins"
  repository = "https://charts.jenkins.io"
  chart      = "jenkins"
  namespace  = kubernetes_namespace.jenkins.metadata[0].name
  values     = [file("${path.module}/jenkins-values.yaml")]
  timeout    = 600
  depends_on = [kubernetes_namespace.jenkins]
}
