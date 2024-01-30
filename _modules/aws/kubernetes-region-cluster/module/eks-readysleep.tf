resource "time_sleep" "external_services" {
  depends_on = [
    kubectl_manifest.alb_ic_config,
    kubectl_manifest.storageclasses,
    kubectl_manifest.external-dns
  ]

  create_duration  = "1m"
  destroy_duration = "3m"
}
