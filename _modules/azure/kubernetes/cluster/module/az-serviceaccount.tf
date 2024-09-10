# Create a Namespace for Karpenter
resource "kubernetes_namespace" "karpenter" {
  metadata {
    name = "karpenter"
  }
}

# Service Account Creation for Karpenter
resource "kubernetes_service_account" "karpenter" {
  metadata {
    name      = var.karpenter_service_account_name
    namespace = kubernetes_namespace.karpenter.metadata[0].name
  }

  depends_on = [kubernetes_namespace.karpenter]
  lifecycle {
    ignore_changes = [metadata]
  }
}

# Create a ClusterRoleBinding to give the service account access to Karpenter's ClusterRole
resource "kubernetes_role_binding" "karpenter" {
  metadata {
    name      = "karpenter-binding"
    namespace = kubernetes_namespace.karpenter.metadata[0].name
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "karpenter-controller"
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.karpenter.metadata[0].name
    namespace = kubernetes_namespace.karpenter.metadata[0].name
  }

  depends_on = [kubernetes_namespace.karpenter]
}

# Create User Assigned Managed Identity (UAMI) for Karpenter
resource "azurerm_user_assigned_identity" "karpenter_identity" {
  resource_group_name = var.resourceGroup
  location            = var.location

  name = var.karpenter_user_assigned_identity_name
}

# Output UAMI details for reference
output "karpenter_identity_client_id" {
  value = azurerm_user_assigned_identity.karpenter_identity.client_id
}

output "karpenter_identity_principal_id" {
  value = azurerm_user_assigned_identity.karpenter_identity.principal_id
}

output "karpenter_identity_id" {
  value = azurerm_user_assigned_identity.karpenter_identity.id
}

# Assign necessary permissions to UAMI (Virtual Machine Contributor role)
resource "azurerm_role_assignment" "karpenter_vm_contributor" {
  principal_id         = azurerm_user_assigned_identity.karpenter_identity.principal_id
  role_definition_name = "Virtual Machine Contributor"
  scope                = "/subscriptions/${var.provider_az_subscription_id}"
}

# Assign Azure Kubernetes Service RBAC Cluster Admin Role to User
resource "azurerm_role_assignment" "aks_rbac_cluster_admin" {
  principal_id         = azurerm_user_assigned_identity.karpenter_identity.principal_id
  role_definition_name = "Azure Kubernetes Service RBAC Cluster Admin"
  scope                = "/subscriptions/${var.provider_az_subscription_id}/resourceGroups/${var.resourceGroup}/providers/Microsoft.ContainerService/managedClusters/${var.name}"
}

# ClusterRoleBinding for secrets access (grant service account access to Kubernetes secrets in kube-system)
resource "kubernetes_cluster_role_binding" "karpenter_secrets_access" {
  metadata {
    name = "karpenter-secrets-access"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"  # Adjust if you want more specific permissions
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.karpenter.metadata[0].name
    namespace = "kube-system"
  }

  depends_on = [kubernetes_service_account.karpenter]
}

# Cluster Role Binding

resource "kubernetes_cluster_role_binding" "karpenter_kube_system_secrets_access" {
  metadata {
    name = "karpenter-kube-system-secrets-access"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"  # Or a more specific role that has access to secrets
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.karpenter.metadata[0].name
    namespace = "kube-system"
  }

  depends_on = [kubernetes_service_account.karpenter]
}


/*#Service account creation

resource "kubernetes_service_account" "karpenter" {
  metadata {
    name      = var.karpenter_service_account_name
    namespace = kubernetes_namespace.karpenter.metadata[0].name
  }

  depends_on = [kubernetes_namespace.karpenter]
  lifecycle {
    ignore_changes = [metadata]
  }
}

resource "kubernetes_role_binding" "karpenter" {
  metadata {
    name      = "karpenter-binding"
    namespace = kubernetes_namespace.karpenter.metadata[0].name
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "karpenter-controller"
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.karpenter.metadata[0].name
    namespace = kubernetes_namespace.karpenter.metadata[0].name
  }

  depends_on = [kubernetes_namespace.karpenter]
}

# User Assigned Managed Identity (UAMI) Creation

resource "azurerm_user_assigned_identity" "karpenter_identity" {
  resource_group_name = var.resourceGroup
  location            = var.location

  name = var.karpenter_user_assigned_identity_name
}

output "karpenter_identity_client_id" {
  value = azurerm_user_assigned_identity.karpenter_identity.client_id
}

output "karpenter_identity_principal_id" {
  value = azurerm_user_assigned_identity.karpenter_identity.principal_id
}

output "karpenter_identity_id" {
  value = azurerm_user_assigned_identity.karpenter_identity.id
}

# Assign permissions to UAMI

resource "azurerm_role_assignment" "karpenter_vm_contributor" {
  principal_id         = azurerm_user_assigned_identity.karpenter_identity.principal_id
  role_definition_name = "Virtual Machine Contributor"
  scope                = "/subscriptions/${var.provider_az_subscription_id}"
}

########Namespace Creation for Karpenter
resource "kubernetes_namespace" "karpenter" {
  metadata {
    name = "karpenter"
  }
}*/

