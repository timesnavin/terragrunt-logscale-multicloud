
data "aws_availability_zones" "available" {
  # all_availability_zones = true
  exclude_names = var.exclude_names
}
resource "random_shuffle" "az" {
  input        = data.aws_availability_zones.available.names
  result_count = length(data.aws_availability_zones.available.names) > var.max_zones ? var.max_zones : length(data.aws_availability_zones.available.names)
}
