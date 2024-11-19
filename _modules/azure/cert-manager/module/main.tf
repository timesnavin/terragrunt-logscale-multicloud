# Install cert-manager via Helm
resource "helm_release" "cert_manager" {
    name = "cert-manager"
    namespace = "cert-manager"
    create_namespace = true
    repository = "https://charts.jetstack.io"
    chart = "cert-manager"
    version = var.cert_manager_version

    set {
      name = "installCRDs"
      value = true
    }

    set {
      name = "extraArgs[0]"
      value = "--enable-certificate-owner-ref=true"
    }
}

resource "kubectl_manifest" "cluster_issuer" {
    yaml_body  = templatefile("${path.module}/cluster-issuer.yaml", {
        email = var.email,
        ingress_class = var.ingress_class,
    })
  
  depends_on = [ helm_release.cert_manager ]
}

/*
# Create User Assigned Managed Identity for cert-manager
resource "azurerm_user_assigned_identity" "cert_manager_identity" {
    name = "${var.cluster_name}-cert-manager-identity"
    resource_group_name = var.resource_group_name
    location = var.location
  
}

# Assign DNS Zone Contributor role to the Managed Identity
resource "azurerm_role_assignment" "cert_manager_dns_zone_contributor" {
    scope = data.azurerm_dns_zone.dns_zone.id  
    role_definition_name = "DNS Zone Contributor"
    principal_id = azurerm_user_assigned_identity.cert_manager_identity.principal_id
  
}

# Data Source to get the Azure DNS zone
data "azurerm_dns_zone" "dns_zone" {
    name = var.azure_dns_zone_name
    resource_group_name = var.azure_dns_resource_group
  
}

# Enable OIDC issuer in AKS 
#resource "azurerm_user_assigned_identity" "cert_manager_identity" {
#    name = "${local.common.name}-{local.partition.name}-cert-manager-identity"
#    resource_group_name = var.resource_group_name
#    location = var.location
#  
#}

# Azure AD Application for cert-manager
resource "azuread_application" "cert_manager_app" {
    display_name = "${var.cluster_name}-cert-manager-app"
  
}

# Service Principal for the Azure AD Application
resource "azuread_service_principal" "cert_manager_sp" {
  #application_id = azuread_application.cert_manager_app.application_id
  client_id = azuread_application.cert_manager_app.client_id
  
}

#Data source to get the AKS node resource group
data "azurerm_kubernetes_cluster" "cluster" {
  name                 =var.cluster_name
  resource_group_name  =var.resource_group_name
}

# Federated Identity Credential
resource "azuread_application_federated_identity_credential" "cert_manager_fic" {
    application_id = azuread_application.cert_manager_app.object_id
    display_name = "cert-manager-fic"
    audiences = ["api://AzureADTokenExchange"]
    issuer = data.azurerm_kubernetes_cluster.cluster.oidc_issuer_url
    subject = "system:serviceaccount:cert-manager:cert-manager"
  
}

# Assign DNS Zone Contributor role to Azure AD Application
resource "azurerm_role_assignment" "cert_manager_app_dns_zone_contributor" {
    scope = data.azurerm_dns_zone.dns_zone.id
    role_definition_name = "DNS Zone Contributor"
    principal_id = azuread_service_principal.cert_manager_sp.id
  
}

# Ensure AKS has OIDC issuer enabled
data "azurerm_kubernetes_cluster" "aks_oidc" {
  name = var.cluster_name
  resource_group_name = var.resource_group_name


  depends_on = [ data.azurerm_kubernetes_cluster.cluster ]
  
}

#Install Azure Workload Identity Webhook via Helm
resource "helm_release" "azure_workload_identity" {
    name = "workload-identity-webhook"
    namespace = "azure-workload-identity-system"
    create_namespace = true
    repository = "https://azure.github.io/azure-workload-identity/charts"
    chart = "workload-identity-webhook"
    version = "1.3.0"

    depends_on = [ data.azurerm_kubernetes_cluster.aks_oidc ]
  
}

# Annotate the cert-manager Service Account
#resource "kubectl_manifest" "cert_manager_service_account" {
#    yaml_body = templatefile("${path.module}/../../kubernetes/platform/module/manifests/helm-manifests/cert-manager-service-account.yaml", {
#        azure_ad_app_id = azuread_application.cert_manager_app.client_id
#    })
#  
#  depends_on = [ helm_release.azure_workload_identity ]
#}

# Annotate the cert-manager Service Account
resource "kubectl_manifest" "cert_manager_service_account" {
    yaml_body = templatefile("${path.module}/cert-manager-service-account.yaml", {
        azure_ad_app_id = azuread_application.cert_manager_app.client_id
    })
  
  depends_on = [ helm_release.azure_workload_identity ]
}

# Install cert-manager via Helm
resource "helm_release" "cert_manager" {
    name = "cert-manager"
    namespace = "cert-manager"
    create_namespace = true
    repository = "https://charts.jetstack.io"
    chart = "cert-manager"
    version = var.cert_manager_version

    set {
      name = "installCRDs"
      value = true
    }
  


# Disable service account creation since it is going to be managed by this config
    set {
        name = "serviceAccount.create"
        value = false
    }

    depends_on = [kubectl_manifest.cert_manager_service_account]

}

# Apply the Cluster Issuer
resource "kubectl_manifest" "cluster_issuer" {
    yaml_body  = templatefile("${path.module}/cluster-issuer.yaml", {
        email = var.email,
        azure_dns_resource_group = var.azure_dns_resource_group,
        azure_dns_zone_name = var.azure_dns_zone_name,
        azure_ad_app_id = azuread_application.cert_manager_app.client_id,
    })
  
  depends_on = [ helm_release.cert_manager ]
}

*/