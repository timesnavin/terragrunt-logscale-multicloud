resource "time_sleep" "addons" {
  create_duration  = "30s"
  destroy_duration = "300s"
  depends_on = [
    helm_release.alb-controller,
    helm_release.cert-manager,
    helm_release.descheduler,
    helm_release.ebs_csi,
    helm_release.efs_csi,
    helm_release.metrics-server,
    time_sleep.karpenter_nodes,
  ]
}