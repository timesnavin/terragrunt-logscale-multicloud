locals {
  cidr    = "2001:db8::/32"
  subnets = cidrsubnets(local.cidr, 1, 1)

  azCount          = 3
  availability_zones = ["1", "2", "3"]
  public_prefixes  = slice(["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"], 0, local.azCount)
  private_prefixes = slice(["10", "11", "12", "13", "14", "15", "16", "17", "18", "19"], local.azCount, local.azCount * 2)

  public_subnets  = slice(cidrsubnets(local.subnets[0], "4", "4", "4", "4", "4", "4", "4"), 0, local.azCount)
  private_subnets = slice(cidrsubnets(local.subnets[1], "4", "4", "4", "4", "4", "4", "4"), 0, local.azCount)
  resource_group_name = "example-resources"
  location = "eastus"  
}