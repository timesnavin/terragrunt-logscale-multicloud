
# resource "helm_release" "metricsserver" {
#   namespace = "kube-system"

#   name       = "metrics-server"
#   repository = "https://kubernetes-sigs.github.io/metrics-server"
#   # repository_username = data.aws_ecrpublic_authorization_token.token.user_name
#   # repository_password = data.aws_ecrpublic_authorization_token.token.password
#   chart   = "metrics-server"
#   version = "v3.11.0"

#   values = [
#     <<-EOT
#       replicas: 2
#       EOT
#   ]


# }
