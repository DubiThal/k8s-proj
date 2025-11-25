data "kubernetes_secret" "grafana" {
  metadata {
    name      = "grafana"
    namespace = "monitoring"
  }
  depends_on = [helm_release.grafana]
}

output "grafana_pass" {
  value = "Run 'terraform output -raw grafana_admin_password' to see the value."
}

output "grafana_url" {
  value = "Access Grafana via its NodePort. Run 'kubectl get svc/grafana -n monitoring' to find the port."
}

output "vault_ui" {
  value = "kubectl port-forward svc/vault 8200:8200 -n vault"
}
