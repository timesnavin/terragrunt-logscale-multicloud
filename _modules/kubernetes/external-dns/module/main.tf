resource "helm_release" "external-dns" {
  namespace        = "external-dns"
  create_namespace = true

  name       = "external-dns"
  repository = "oci://registry-1.docker.io/bitnamicharts/external-dns"
  chart      = "external-dns"
  version    = "6.28.6"

  wait = false

  values = [
    <<-EOT
    provider: aws
    replicaCount: 2
    podAntiAffinityPreset: hard
    EOT
  ]
}

