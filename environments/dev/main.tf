
module "network" {
  source = "../../modules/network"

  project_name       = var.project_name
  vpc_cidr           = "10.0.0.0/16"
  availability_zones = ["us-east-1a", "us-east-1b"]

  public_subnet_cidrs = [
    "10.0.1.0/24",
    "10.0.2.0/24"
  ]

  private_app_subnet_cidrs = [
    "10.0.11.0/24",
    "10.0.12.0/24"
  ]

  private_db_subnet_cidrs = [
    "10.0.21.0/24",
    "10.0.22.0/24"
  ]

  enable_nat_gateway = var.enable_nat_gateway
  tags               = local.common_tags
}

module "security" {
  source = "../../modules/security"

  project_name = var.project_name
  vpc_id       = module.network.vpc_id

  private_app_port = 80
  private_db_port  = 3306

  tags = local.common_tags
}
module "alb" {
  source = "../../modules/alb"

  project_name = var.project_name

  vpc_id = module.network.vpc_id

  public_subnet_ids = module.network.public_subnet_ids

  alb_security_group_id = module.security.alb_security_group_id

  target_port = 80

  health_check_path          = "/"
  origin_verify_header_value = var.origin_verify_header_value

  tags = local.common_tags
}
module "compute" {
  source = "../../modules/compute"

  project_name = var.project_name

  private_subnet_ids = module.network.private_app_subnet_ids

  app_security_group_id = module.security.app_security_group_id

  target_group_arn = module.alb.target_group_arn

  instance_type = "t3.micro"

  min_size                  = 2
  desired_capacity          = 2
  max_size                  = 4
  iam_instance_profile_name = module.iam.ec2_instance_profile_name
  tags                      = local.common_tags
}

module "database" {
  source = "../../modules/database"

  project_name = var.project_name

  private_db_subnet_ids = module.network.private_db_subnet_ids

  database_security_group_id = module.security.database_security_group_id

  database_name     = "appdb"
  database_username = "dbadmin"

  database_instance_class = "db.t3.micro"

  allocated_storage     = 20
  max_allocated_storage = 100

  multi_az = var.multi_az

  tags = local.common_tags
}

module "monitoring" {
  source = "../../modules/monitoring"

  project_name = var.project_name
  aws_region   = var.aws_region

  alb_arn          = module.alb.alb_arn
  target_group_arn = module.alb.target_group_arn

  autoscaling_group_name = module.compute.autoscaling_group_name

  db_instance_id = module.database.db_instance_id

  # Add your email address to receive notifications.
  # Leave empty to create alarms without an email subscription.
  alarm_email = ""

  tags = local.common_tags
}

module "iam" {
  source = "../../modules/iam"

  project_name = var.project_name

  # The current Nginx application does not need database credentials.
  secret_arn = null

  tags = local.common_tags
}


module "storage" {
  source = "../../modules/storage"

  project_name = var.project_name

  # Replace with a globally unique name for your AWS account.
  bucket_name = var.s3_bucket_name

  tags = local.common_tags
}


module "cdn" {
  source = "../../modules/cdn"

  project_name = var.project_name

  alb_dns_name = module.alb.alb_dns_name

  s3_bucket_id                   = module.storage.bucket_id
  s3_bucket_arn                  = module.storage.bucket_arn
  s3_bucket_regional_domain_name = module.storage.bucket_regional_domain_name
  waf_web_acl_arn                = module.waf.web_acl_arn
  origin_verify_header_value     = var.origin_verify_header_value

  tags = local.common_tags
}


module "waf" {
  source = "../../modules/waf"

  project_name = var.project_name
  rate_limit   = 1000

  tags = local.common_tags
}
