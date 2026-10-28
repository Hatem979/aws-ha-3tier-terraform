#Security Group for the Application Load Balancer
resource "aws_security_group" "alb" {
  name        = "${var.project_name}-alb-sg"
  description = "control inbount traffic to the ALB"
  vpc_id      = var.vpc_id
  tags        = merge(var.tags, { Name = "${var.project_name}-alb-sg" })
}
# Security Group for the application servers
resource "aws_security_group" "private_app" {
  name        = "${var.project_name}-private-app-sg"
  description = "Allow application traffic from the ALB only"
  vpc_id      = var.vpc_id
  tags        = merge(var.tags, { Name = "${var.project_name}-private-app-sg" })
}
# Security Group for the database
resource "aws_security_group" "private_db" {
  name        = "${var.project_name}-private-db-sg"
  description = "Allow database traffic from the private application servers"
  vpc_id      = var.vpc_id
  tags        = merge(var.tags, { Name = "${var.project_name}-private-db-sg" })
}
# ALB: allow HTTP from cloudfront origin-facing IPs
resource "aws_vpc_security_group_ingress_rule" "cloudfront_http" {
  security_group_id = aws_security_group.alb.id
  description       = "Allow HTTP only from CloudFront origin-facing IPs"

  from_port   = 80
  to_port     = 80
  ip_protocol = "tcp"

  referenced_security_group_id = null
  cidr_ipv4                    = null
  prefix_list_id               = data.aws_ec2_managed_prefix_list.cloudfront_origin_facing.id
}
# ALB: allow HTTPS from approved IPv4 ranges
resource "aws_vpc_security_group_ingress_rule" "alb_https" {
  for_each          = toset(var.alb_ingress_cidr)
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
  cidr_ipv4         = each.value
  security_group_id = aws_security_group.alb.id
  description       = "Allow HTTPS traffic to the ALB"
}
# ALB -> Application
resource "aws_vpc_security_group_egress_rule" "alb_to_app" {
  security_group_id            = aws_security_group.alb.id
  referenced_security_group_id = aws_security_group.private_app.id
  description                  = "Forward traffic from ALB to application"
  from_port                    = var.private_app_port
  to_port                      = var.private_app_port
  ip_protocol                  = "tcp"
}

# Application: accept traffic only from the ALB
resource "aws_vpc_security_group_ingress_rule" "app_from_alb" {
  security_group_id            = aws_security_group.private_app.id
  referenced_security_group_id = aws_security_group.alb.id
  description                  = "Allow application traffic from ALB only"
  from_port                    = var.private_app_port
  to_port                      = var.private_app_port
  ip_protocol                  = "tcp"
}

# Application -> Database
resource "aws_vpc_security_group_egress_rule" "app_to_database" {
  security_group_id            = aws_security_group.private_app.id
  referenced_security_group_id = aws_security_group.private_db.id
  description                  = "Allow application to connect to database"
  from_port                    = var.private_db_port
  to_port                      = var.private_db_port
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "app_https_egress" {
  security_group_id = aws_security_group.private_app.id

  description = "Allow HTTPS outbound traffic for package downloads"

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 443
  to_port     = 443
  ip_protocol = "tcp"
}


# Database: accept connections only from the application tier
resource "aws_vpc_security_group_ingress_rule" "database_from_app" {
  security_group_id            = aws_security_group.private_db.id
  referenced_security_group_id = aws_security_group.private_app.id
  description                  = "Allow database connections from app only"
  from_port                    = var.private_db_port
  to_port                      = var.private_db_port
  ip_protocol                  = "tcp"
}
data "aws_ec2_managed_prefix_list" "cloudfront_origin_facing" {
  name = "com.amazonaws.global.cloudfront.origin-facing"
}
