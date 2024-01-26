# ---------------------------------------------------------------------------------------------------------------------
# COMMON TERRAGRUNT CONFIGURATION
# This is the common component configuration for mysql. The common variables for each environment to
# deploy mysql are defined here. This configuration will be merged into the environment configuration
# via an include block.
# ---------------------------------------------------------------------------------------------------------------------

# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder. If any environment
# needs to deploy a different module version, it should redefine this block with a different ref to override the
# deployed version.

terraform {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-vpc.git?ref=v5.5.1"
}


# ---------------------------------------------------------------------------------------------------------------------
# Locals are named constants that are reusable within the configuration.
# ---------------------------------------------------------------------------------------------------------------------
locals {
  partition = yamldecode(file(find_in_parent_folders("partition.yaml")))
  region    = yamldecode(file(find_in_parent_folders("region.yaml")))

  cidr = "10.0.0.0/16"
}

dependency "azs" {
  config_path = "${get_terragrunt_dir()}/../azs/"
}

# ---------------------------------------------------------------------------------------------------------------------
# MODULE PARAMETERS
# These are the variables we have to pass in to use the module. This defines the parameters that are common across all
# environments.
# ---------------------------------------------------------------------------------------------------------------------
inputs = {
  name = "${local.partition.name}-${local.region.name}"
  cidr = local.cidr

  azs             = dependency.azs.outputs.az_names
  
  private_subnets = [for k, v in dependency.azs.outputs.az_names : cidrsubnet(local.cidr, 4, k)]
  public_subnets  = [for k, v in dependency.azs.outputs.az_names : cidrsubnet(local.cidr, 8, k + 48)]

  enable_nat_gateway     = true
  enable_vpn_gateway     = false
  single_nat_gateway     = false
  enable_dns_hostnames   = true
  one_nat_gateway_per_az = true


  enable_flow_log                                 = true
  create_flow_log_cloudwatch_iam_role             = true
  create_flow_log_cloudwatch_log_group            = true
  flow_log_cloudwatch_log_group_retention_in_days = 1

  public_subnet_ipv6_prefixes                    = range(0,length(dependency.azs.outputs.az_names))
  public_subnet_assign_ipv6_address_on_creation  = true
  private_subnet_ipv6_prefixes                   = range(length(dependency.azs.outputs.az_names),length(dependency.azs.outputs.az_names)*2)
  private_subnet_assign_ipv6_address_on_creation = true

  public_subnet_tags = {
    "kubernetes.io/role/elb"                                             = "1"
    "kubernetes.io/cluster/${local.partition.name}-${local.region.name}" = "shared"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${local.partition.name}-${local.region.name}" = "shared"
    "kubernetes.io/role/internal-elb"                                    = "1"
    "karpenter.sh/discovery"                                             = "${local.partition.name}-${local.region.name}"
  }

  public_dedicated_network_acl = true
  
  private_dedicated_network_acl = true
}