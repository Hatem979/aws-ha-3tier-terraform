output "vpc_id" {
  value       = aws_vpc.my_vpc.id
  description = "The ID of the VPC."
}
output "vpc_cidr" {
  value       = aws_vpc.my_vpc.cidr_block
  description = "The CIDR block of the VPC."
}
output "availability_zones" {
  value       = var.availability_zones
  description = "The availability zones used for the subnets."
}
output "public_subnet_ids" {
  value       = aws_subnet.public[*].id
  description = "The IDs of the public subnets."
}
output "private_app_subnet_ids" {
  value       = aws_subnet.private_app[*].id
  description = "The IDs of the private application subnets."
}
output "private_db_subnet_ids" {
  value       = aws_subnet.private_db[*].id
  description = "The IDs of the private database subnets."
}
output "public_route_table_id" {
  value       = aws_route_table.public.id
  description = "The ID of the public route table."
}
output "private_app_route_table_id" {
  value       = aws_route_table.private_app[*].id
  description = "The ID of the private application route table."
}
output "nat_gateway_ids" {
  value = var.enable_nat_gateway ? [
    for az in var.availability_zones :
    aws_nat_gateway.NGW[az].id
  ] : []
  description = "The IDs of the NAT Gateways."
}   