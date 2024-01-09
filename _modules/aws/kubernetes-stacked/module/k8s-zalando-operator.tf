resource "helm_release" "zalando-operator" {
    depends_on = [
    time_sleep.karpenter_nodes,
    helm_release.karpenter
  ]

  namespace        = "postgres-operator"
  create_namespace = true

  name       = "postgres-operator"
  repository = "https://opensource.zalando.com/postgres-operator/charts/postgres-operator"
  chart      = "postgres-operator"
  version    = "1.10.1"

  values = [templatefile("./k8s-zalando-operator.yaml",{region=data.aws_eks_cluster.this.region})]
}
