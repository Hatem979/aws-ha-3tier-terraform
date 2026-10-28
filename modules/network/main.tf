#VPC
resource "aws_vpc" "my_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = merge(local.common_tags,
    {
      Name = "${var.project_name}-vpc"
    }
  )
}
#Internet Gateway
resource "aws_internet_gateway" "IGW" {
  vpc_id = aws_vpc.my_vpc.id
  tags = merge(local.common_tags,
    {
      Name = "${var.project_name}-igw"
    }
  )
}
#Public Subnets
resource "aws_subnet" "public" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true
  tags = merge(local.common_tags,
    {
      Name = "${var.project_name}-public-subnet-${count.index + 1}"
    }
  )
}
#Private Application Subnets
resource "aws_subnet" "private_app" {
  count                   = length(var.private_app_subnet_cidrs)
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = var.private_app_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = false
  tags = merge(local.common_tags,
    {
      Name = "${var.project_name}-private-app-subnet-${count.index + 1}"
      Tier = "application"
    }
  )
}
#Private Database Subnets
resource "aws_subnet" "private_db" {
  count                   = length(var.private_db_subnet_cidrs)
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = var.private_db_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = false
  tags = merge(local.common_tags,
    {
      Name = "${var.project_name}-private-db-subnet-${count.index + 1}"
      Tier = "database"
    }
  )
}
#Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.my_vpc.id
  tags = merge(local.common_tags,
    {
      Name = "${var.project_name}-public-rt"
    }
  )
}
#Route for Public Route Table to Internet Gateway
resource "aws_route" "public_internet_access" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.IGW.id
}
#Associate each Public Subnets with the Public Route Table
resource "aws_route_table_association" "public" {
  count          = length(var.public_subnet_cidrs)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}
# Private Application Route Tables: one per AZ
resource "aws_route_table" "private_app" {
  count  = length(var.availability_zones)
  vpc_id = aws_vpc.my_vpc.id
  tags = merge(local.common_tags,
    {
      Name = "${var.project_name}-private-app-rt-${count.index + 1}"
    }
  )
}
resource "aws_route_table_association" "private_app" {
  count          = length(var.availability_zones)
  subnet_id      = aws_subnet.private_app[count.index].id
  route_table_id = aws_route_table.private_app[count.index].id
}

# Private Database Route Tables: one per AZ
resource "aws_route_table" "private_db" {
  count = length(var.availability_zones)

  vpc_id = aws_vpc.my_vpc.id

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-db-rt-${count.index + 1}"
  })
}

resource "aws_route_table_association" "private_db" {
  count = length(var.availability_zones)

  subnet_id      = aws_subnet.private_db[count.index].id
  route_table_id = aws_route_table.private_db[count.index].id
}
# Elastic IPs for optional NAT Gateways
resource "aws_eip" "nat" {
  for_each = var.enable_nat_gateway ? local.az_index_map : {}
  domain   = "vpc"
  tags = merge(local.common_tags,
    {
      Name = "${var.project_name}-nat-eip-${each.value + 1}"
    }
  )
}
# Optional NAT Gateway: one per AZ
resource "aws_nat_gateway" "NGW" {
  for_each      = var.enable_nat_gateway ? local.az_index_map : {}
  allocation_id = aws_eip.nat[each.key].id
  subnet_id     = aws_subnet.public[each.value].id
  depends_on    = [aws_internet_gateway.IGW]
  tags = merge(local.common_tags,
    {
      Name = "${var.project_name}-nat-gw-${each.value + 1}"
    }
  )
}
# Allow application subnets to access the internet through
# the NAT Gateway in the same AZ, when NAT is enabled.
resource "aws_route" "private_app_nat_access" {
  for_each               = var.enable_nat_gateway ? local.az_index_map : {}
  route_table_id         = aws_route_table.private_app[each.value].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.NGW[each.key].id
}
# S3 Gateway Endpoint
resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.my_vpc.id
  service_name      = "com.amazonaws.${data.aws_region.current.name}.s3"
  vpc_endpoint_type = "Gateway"

  route_table_ids = concat(
    aws_route_table.private_app[*].id,
    aws_route_table.private_db[*].id
  )

  tags = merge(local.common_tags,
    {
      Name = "${var.project_name}-s3-gateway-endpoint"
    }
  )
}

data "aws_region" "current" {}