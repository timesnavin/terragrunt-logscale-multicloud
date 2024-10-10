locals {
  # IPv6 /32 CIDR for the VNet
  cidr = "2001:db8::/32"

  # First, split the /32 into multiple /48 subnets (at least 2 for public/private)
  subnets_48 = cidrsubnets(local.cidr, 16, 16)

  # Then, split the first /48 into /64 subnets for public subnets
  public_subnets  = cidrsubnets(local.subnets_48[0], 16)  # First /48 split into /64 for public subnets

  # Split the second /48 into /64 subnets for private subnets
  private_subnets = cidrsubnets(local.subnets_48[1], 16)  # Second /48 split into /64 for private subnets

  azCount = 3
  availability_zones = ["1", "2", "3"]

  resource_group_name = "example-resources"
  location            = "eastus"
}