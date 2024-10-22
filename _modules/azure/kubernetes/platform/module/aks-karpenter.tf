locals {

}

resource "null_resource" "write_kubeconfig" {
  provisioner "local-exec" {
    command = <<EOT
      echo '${var.kubeconfig_path}' > /tmp/kubeconfig
    EOT
  }

  triggers = {
    always_run = "${timestamp()}"
  }
}


# Karpenter installation
resource "null_resource" "configure_values" {
  provisioner "local-exec" {
    command = <<EOT
    ./configure-values.sh\
        ${var.cluster_name} \
        ${var.resource_group_name} \
        ${var.karpenter_service_account_name} \
        ${var.karpenter_user_assigned_identity_name}
    EOT

    environment = {
      #KUBECONFIG = var.kubeconfig_path
      KUBECONFIG = "/tmp/kubeconfig"
      AZURE_SUBSCRIPTION_ID = var.provider_az_subscription_id
      VNET_SUBNET_ID = ""
    }
  }

  triggers = {
    always_run = "${timestamp()}"
  }
}




resource "null_resource" "install_karpenter" {
  provisioner "local-exec" {
    command = <<EOT
      helm upgrade --install karpenter oci://mcr.microsoft.com/aks/karpenter/karpenter \
        --namespace karpenter \
        --create-namespace \
        --values ./karpenter-values.yaml
    EOT

    environment = {
      KUBECONFIG = "/tmp/kubeconfig"
    }
  }

  depends_on = [
    null_resource.configure_values,
    null_resource.write_kubeconfig
  ]
}
###############################New Addition


resource "time_sleep" "karpenter" {
  depends_on       = [null_resource.install_karpenter]
  destroy_duration = "90s"
}