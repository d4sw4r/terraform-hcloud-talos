data "helm_template" "hcloud_ccm" {
  name      = "hcloud-cloud-controller-manager"
  namespace = "kube-system"

  repository = "https://charts.hetzner.cloud"
  chart      = "hcloud-cloud-controller-manager"
  version    = "1.19.0"

  set {
    name  = "networking.enabled"
    value = "true"
  }

  set {
    name  = "networking.clusterCIDR"
    value = local.pod_ipv4_cidr
  }
}

data "kubectl_file_documents" "hcloud_ccm" {
  content = data.helm_template.hcloud_ccm.manifest
}

resource "kubectl_manifest" "apply_hcloud_ccm" {
  for_each   = var.control_plane_count > 0 ? data.kubectl_file_documents.hcloud_ccm.manifests : {}
  yaml_body  = each.value
  depends_on = [time_sleep.cilium_settle_down]
}
