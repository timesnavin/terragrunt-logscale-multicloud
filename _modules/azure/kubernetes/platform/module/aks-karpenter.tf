/*
provider "helm" {
  kubernetes {
    config_path = var.kubeconfig_path
  }
}

resource "helm_release" "karpenter" {
  name       = "karpenter"
  namespace  = "karpenter"
  repository = "https://charts.karpenter.sh/"
  chart      = "karpenter"
  version    = "0.6.3"  # Use the latest version compatible with your setup

  set {
    name  = "serviceAccount.create"
    value = "true"
  }

  set {
    name  = "controller.clusterName"
    value = var.cluster_name
  }

  set {
    name  = "controller.clusterEndpoint"
    value = data.azurerm_kubernetes_cluster.cluster.fqdn
  }

  set {
    name  = "controller.aws.defaultInstanceProfile"
    value = var.instance_profile_name
  }

  set {
    name  = "settings.aws.interruptionQueueName"
    value = "karpenter-interruption-queue"
  }

  set {
    name  = "settings.aws.enableInterruptionHandling"
    value = "true"
  }
}

variable "kubeconfig_path" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "instance_profile_name" {
  type = string
}
*/