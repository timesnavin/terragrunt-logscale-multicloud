# Step 1: Run configure-values.sh to generate karpenter-values.yaml
/*resource "null_resource" "configure_values" {
  provisioner "local-exec" {
    command = <<EOT
      curl -L https://github.com/Azure/karpenter-provider-azure/releases/download/v0.1.0/configure-values.sh -o configure-values.sh
      chmod +x configure-values.sh
     ./configure-values.sh \
        --cluster-name ${module.aks.cluster_name} \
        --resource-group ${module.aks.resource_group_name} \
        --location ${module.aks.location} \
        --subscription-id ${var.azure_subscription_id} \
        --client-id ${var.azure_client_id} \
        --client-secret ${var.azure_client_secret} \
        --tenant-id ${var.azure_tenant_id}
    EOT

    environment = {
      KUBECONFIG = module.aks.kubeconfig_path
    }

    triggers = {
      always_run = "${timestamp()}"
    }
  }*/
###################################

resource "null_resource" "configure_values" {
  provisioner "local-exec" {
    command = <<EOT
      curl -L https://github.com/Azure/karpenter-provider-azure/releases/download/v0.1.0/configure-values.sh -o ./configure-values.sh
      chmod +x ./configure-values.sh
      ./configure-values.sh \
        --cluster-name ${dependency.cluster.outputs.cluster_name} \
        --resource-group ${dependency.cluster.outputs.resource_group_name} \
        --location ${dependency.cluster.outputs.location}
    EOT

    environment = {
      KUBECONFIG = module.aks.kubeconfig_path
    }

    triggers = {
      always_run = "${timestamp()}"
    }
  }

  #depends_on = [module.aks]
  depends_on = [ dependency.cluster ]
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
      KUBECONFIG = dependency.cluster.outputs.kubeconfig_path
    }
  }

  depends_on = [null_resource.configure_values]
}

