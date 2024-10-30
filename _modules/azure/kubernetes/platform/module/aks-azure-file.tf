#Create User Assigned Managed Identity for Azure File CSI Driver
resource "azurerm_user_assigned_identity" "file_csi_driver_identity" {
  name                  ="${var.cluster_name}-file-csi-driver-identity"
  resource_group_name   = var.resource_group_name
  location              = var.location
  
}

# Assign Necessary Roles to the the Managed Identity
/*
data "azurerm_kubernetes_cluster" "cluster" {
  name                  =azurerm_kubernetes_cluster.aks.name
  resource_group_name   = data.azurerm_kubernetes_cluster.cluster.resource_group_name
  
}
*/

#Assign 'Contributor' Role to the Managed Identity on the Node Resource Group
resource "azurerm_role_assignment" "file_csi_driver_identity_role" {
  scope                 =data.azurerm_resource_group.node_resource_group.id
  role_definition_name  ="Contributor"
  principal_id          =azurerm_user_assigned_identity.file_csi_driver_identity.principal_id 

  depends_on = [ data.azurerm_kubernetes_cluster.cluster ] 
  
}

#Deploy the Azure File CSI Driver Using Kubernetes Manfiests
resource "kubectl_manifest" "azure_file_csi_driver" {
  for_each = fileset("{path.module}/manifests/azure-file-csi-driver", "*.yaml")
  yaml_body = templatefile("{path.module}/manfiests/azure-file-csi-driver/${each.value}",{
    file_csi_driver_client_id = azurerm_user_assigned_identity.file_csi_driver_identity.client_id
  } )

  depends_on = [ 
    data.azurerm_kubernetes_cluster.cluster,
    azurerm_role_assignment.disk_csi_driver_identity_role,
   ]
  
}