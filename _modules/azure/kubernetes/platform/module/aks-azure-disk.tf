# Create User Assigned Managed Identity for the Azure Disk CSI Driver
resource "azurerm_user_assigned_identity" "disk_csi_driver_identity" {
  name                ="${var.cluster_name}-disk-csi-driver-identity"
  resource_group_name =var.resource_group_name
  location            =var.location 
 }

# Assign the Managed Identity neceesary permissions
resource "azurerm_role_assignment" "disk_csi_driver_identity_role" {
  scope                =data.azurerm_resource_group.node_resource_group.id
  role_definition_name ="Contributor"
  principal_id         =azurerm_user_assigned_identity.disk_csi_driver_identity.principal_id  
}

#Data source to get the AKS node resource group
data "azurerm_kubernetes_cluster" "cluster" {
  name                 =var.cluster_name
  resource_group_name  =var.resource_group_name
}

data "azurerm_resource_group" "node_resource_group" {
  name                 = data.azurerm_kubernetes_cluster.cluster.node_resource_group
}
/*
#Deploy the Azure Disk CSI Driver using Helm
resource "helm_release" "azure_disk_csi_driver" {
  name                 ="azure-disk-csi-driver"
  namespace            ="kube-system"
  chart                ="./azuredisk-csi-driver-1.31.0.tgz"

  set{
    name               ="control.serviceAccount.annotations.azure\\.workload\\.identity\\/client-id"
    value              =azurerm_user_assigned_identity.disk_csi_driver_identity.client_id
  }

  depends_on = [ azurerm_role_assignment.disk_csi_driver_identity_role ]
  
}
*/