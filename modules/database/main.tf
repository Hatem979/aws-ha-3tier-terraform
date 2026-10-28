resource "aws_db_subnet_group" "db_subnet" {
  name        = "${var.project_name}-db-subnet-group"
  description = "Private subnets for the RDS database"

  subnet_ids = var.private_db_subnet_ids

  tags = merge(var.tags, {
    Name = "${var.project_name}-db-subnet-group"
  })
}

resource "aws_db_instance" "database" {
  identifier = "${var.project_name}-mysql"

  engine         = "mysql"
  instance_class = var.database_instance_class

  db_name  = var.database_name
  username = var.database_username

  manage_master_user_password = true

  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage
  storage_type          = "gp3"
  storage_encrypted     = true

  db_subnet_group_name   = aws_db_subnet_group.db_subnet.name
  vpc_security_group_ids = [var.database_security_group_id]

  publicly_accessible = false
  multi_az            = var.multi_az

  port = 3306

  backup_retention_period = 0
  copy_tags_to_snapshot   = true

  auto_minor_version_upgrade = true
  apply_immediately          = false

  deletion_protection = false
  skip_final_snapshot = true

  tags = merge(var.tags, {
    Name = "${var.project_name}-mysql"
  })
}