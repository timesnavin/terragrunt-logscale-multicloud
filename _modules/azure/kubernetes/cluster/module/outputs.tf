# output "az_names" {
#   value = random_shuffle.az.result
# }
locals {
  cidr    = "10.0.0.0/16"
  subnets = cidrsubnets(local.cidr, 1, 1)

  # azCount          = length(random_shuffle.az.result)
  # public_prefixes  = slice(["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"], 0, local.azCount)
  # private_prefixes = slice(["10", "11", "12", "13", "14", "15", "16", "17", "18", "19"], local.azCount, local.azCount * 2)

  # public_subnets  = slice(cidrsubnets(local.subnets[0], "4", "4", "4", "4", "4", "4", "4"), 0, local.azCount)
  # private_subnets = slice(cidrsubnets(local.subnets[1], "4", "4", "4", "4", "4", "4", "4"), 0, local.azCount)

}

# output "public_subnet_ipv6_prefixes" {
#   value = local.public_prefixes
# }
# output "private_subnet_ipv6_prefixes" {
#   value = local.private_prefixes
# }

# output "cidr" {
#   value = local.cidr
# }
# output "public_subnets" {
#   value = local.public_subnets
# }
# output "private_subnets" {
#   value = local.private_subnets
# }
