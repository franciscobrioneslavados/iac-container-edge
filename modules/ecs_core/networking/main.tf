data "aws_availability_zones" "available" {
  # Exclude local zones
  state = "available"
  # Exclude zones that require opt-in
  # This is useful for regions that have local zones or zones that require opt-in
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

locals {
  azs = slice(data.aws_availability_zones.available.names, 0, 3)
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5" #5.19.0

  name            = "vpc-${var.environment}-${var.project}"
  cidr            = var.vpc_cidr
  azs             = slice(data.aws_availability_zones.available.names, 0, 2)
  private_subnets = [for i in range(2) : cidrsubnet(var.vpc_cidr, 4, i)]
  public_subnets  = [for i in range(2) : cidrsubnet(var.vpc_cidr, 4, i + 2)]

  enable_nat_gateway      = true
  single_nat_gateway      = var.single_nat_gateway
  one_nat_gateway_per_az  = !var.single_nat_gateway
  enable_dns_hostnames    = true
  map_public_ip_on_launch = true

  tags = merge(
    {
      Name = "vpc-${var.environment}-${var.project}"
    },
    var.global_tags
  )
}

