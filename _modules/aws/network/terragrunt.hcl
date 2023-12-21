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
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-vpc.git?ref=v5.4.0"
}


# ---------------------------------------------------------------------------------------------------------------------
# Locals are named constants that are reusable within the configuration.
# ---------------------------------------------------------------------------------------------------------------------
locals {
  foundation = yamldecode(file(find_in_parent_folders("foundation.yaml")))
  provider   = yamldecode(file(find_in_parent_folders("provider.yaml")))
  region     = yamldecode(file(find_in_parent_folders("region.yaml")))



  network_acls = {
    default_inbound = [
      {
        rule_number = 800
        rule_action = "allow"
        from_port   = 0
        to_port     = 65535
        protocol    = "-1"
        cidr_block  = "10.0.0.0/20"
      },
    ]
    default_outbound = [
      {
        rule_number = 900
        rule_action = "allow"
        from_port   = 0
        to_port     = 65535
        protocol    = "tcp"
        cidr_block  = "0.0.0.0/0"
      },
      {
        rule_number = 901
        rule_action = "allow"
        from_port   = 0
        to_port     = 65535
        protocol    = "udp"
        cidr_block  = "0.0.0.0/0"
      }
    ]
    public_inbound = [
      {
        rule_number = 100
        rule_action = "allow"
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_block  = "0.0.0.0/0"
      },
      {
        rule_number = 110
        rule_action = "allow"
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_block  = "0.0.0.0/0"
      },
    ]
    public_outbound = [
      {
        rule_number = 100
        rule_action = "allow"
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_block  = "0.0.0.0/0"
      },
      {
        rule_number = 110
        rule_action = "allow"
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_block  = "0.0.0.0/0"
      },
      {
        rule_number = 120
        rule_action = "allow"
        from_port   = 1433
        to_port     = 1433
        protocol    = "tcp"
        cidr_block  = "10.0.100.0/22"
      },
      {
        rule_number = 130
        rule_action = "allow"
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_block  = "10.0.100.0/22"
      },
      {
        rule_number = 140
        rule_action = "allow"
        icmp_code   = -1
        icmp_type   = 8
        protocol    = "icmp"
        cidr_block  = "10.0.0.0/22"
      },
      {
        rule_number     = 150
        rule_action     = "allow"
        from_port       = 90
        to_port         = 90
        protocol        = "tcp"
        ipv6_cidr_block = "::/0"
      },
    ]
    elasticache_outbound = []
  }

}


# ---------------------------------------------------------------------------------------------------------------------
# MODULE PARAMETERS
# These are the variables we have to pass in to use the module. This defines the parameters that are common across all
# environments.
# ---------------------------------------------------------------------------------------------------------------------
inputs = {
  name = local.provider.aws.name
  cidr = local.region.network.address_space

  azs             = ["us-east-1a", "us-east-1b", "us-east-1c"]
  private_subnets = local.region.network.private_subnets
  public_subnets  = local.region.network.public_subnets
  intra_subnets   = local.region.network.intra_subnets

  enable_nat_gateway     = true
  enable_vpn_gateway     = false
  single_nat_gateway     = false
  enable_dns_hostnames   = true
  one_nat_gateway_per_az = true


  enable_flow_log                                 = true
  create_flow_log_cloudwatch_iam_role             = true
  create_flow_log_cloudwatch_log_group            = true
  flow_log_cloudwatch_log_group_retention_in_days = 1
  # enable_ipv6                     = true
  # assign_ipv6_address_on_creation = true

  # private_subnet_assign_ipv6_address_on_creation = false

  # public_subnet_ipv6_prefixes  = [0, 1, 2]
  # private_subnet_ipv6_prefixes = [3, 4, 5]

  public_subnet_tags = {
    "kubernetes.io/role/elb" = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/eks"       = "shared"
    "kubernetes.io/role/internal-elb" = "1"
    "karpenter.sh/discovery"          = local.provider.aws.name
  }

  // default_network_acl_ingress = 
  public_dedicated_network_acl = true
  // public_inbound_acl_rules     = concat(local.network_acls["default_inbound"], local.network_acls["public_inbound"])
  // public_outbound_acl_rules    = concat(local.network_acls["default_outbound"], local.network_acls["public_outbound"])

  // public_inbound_acl_rules = [
  //   {
  //     "action" : "allow",
  //     "cidr_block" : "0.0.0.0/0",
  //     "protocol" : "tcp",
  //     "rule_no" : 100,
  //     "from_port" : 443,
  //     "to_port" : 443
  //   },
  //   {
  //     "action" : "allow",
  //     "cidr_block" : "10.0.0.0/20",
  //     "protocol" : "-1",
  //     "rule_no" : 101,
  //     "from_port" : 0,
  //     "to_port" : 0
  //   },
  //   // { "action" : "allow",
  //   //   "ipv6_cidr_block" : "::/0",
  //   //   "protocol" : "tcp",
  //   //   "rule_no" : 200,
  //   //   "from_port" : 443,
  //   //   "to_port" : 443
  //   // }
  // ]

  private_dedicated_network_acl = true
}