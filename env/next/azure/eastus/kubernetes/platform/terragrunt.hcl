# ---------------------------------------------------------------------------------------------------------------------
# We don't need to override any of the common parameters for this environment, so we don't specify any inputs.
# ---------------------------------------------------------------------------------------------------------------------
include "root" {
  path = find_in_parent_folders()
}

include "root" {
  path = "${dirname(find_in_parent_folders())}/_providers/terragrunt_az_aks_region.hcl"
}

/*terraform {
  source = "${dirname(find_in_parent_folders())}/_modules/azure/kubernetes/cluster/module/"
}*/

include "module" {
  path   = "${dirname(find_in_parent_folders())}/_modules/azure/kubernetes/platform/terragrunt.hcl"
  expose = true
}
dependency "cluster" {
  config_path = "../cluster/"  # Reference the env folder where the cluster state is stored
}

inputs = {
  cluster_name        = dependency.cluster.outputs.cluster_name
  resource_group_name = dependency.cluster.outputs.resource_group_name
  location            = dependency.cluster.outputs.location
  kubeconfig_path     = dependency.cluster.outputs.kubeconfig_path
  instance_profile    = ""
  karpenter_service_account_name      = "karpenter-sa"  # Define the actual service account name
  karpenter_user_assigned_identity_name = "karpenter-identity"  # Define the actual identity name  
}

