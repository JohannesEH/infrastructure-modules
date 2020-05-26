resource "aws_subnet" "subnet" {
  count                   = var.deploy ? length(var.subnets) : 0
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  cidr_block              = var.subnets[count.index]
  vpc_id                  = var.vpc_id
  map_public_ip_on_launch = true # needed to support managed node groups

  tags = {
    "Name"                                      = "${var.name}-${data.aws_availability_zones.available.names[count.index]}"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }
}

