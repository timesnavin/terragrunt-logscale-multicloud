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
  source = "${dirname(find_in_parent_folders())}/_modules/aws/route53/ns/module/"
}

dependency "zone" {
  config_path = "${get_terragrunt_dir()}/../zone/"
  mock_outputs = {
    name_servers = ["n1.example.com", "n2.example.com"]
  }
}
# ---------------------------------------------------------------------------------------------------------------------
# Locals are named constants that are reusable within the configuration.
# ---------------------------------------------------------------------------------------------------------------------
locals {
  foundation = yamldecode(file(find_in_parent_folders("foundation.yaml")))
  provider   = yamldecode(file(find_in_parent_folders("provider.yaml")))
  global     = yamldecode(file(find_in_parent_folders("global.yaml")))

}


inputs = {
  zone_id = "${local.global.dns.parent_zone}"
  records = [{
    name    = "${local.global.partition}.${local.global.domain_name}"
    type    = "NS"
    ttl     = 600
    records = dependency.zone.outputs.name_servers

  }]

}