output "ec2_role_arn" {
  description = "ARN of the IAM Role assigned to EC2."
  value       = aws_iam_role.ec2_role.arn
}

output "ec2_role_name" {
  description = "Name of the IAM Role assigned to EC2."
  value       = aws_iam_role.ec2_role.name
}

output "ec2_instance_profile_name" {
  description = "Name of the Instance Profile attached to EC2 instances."
  value       = aws_iam_instance_profile.ec2_profile.name
}

output "secret_read_policy_created" {
  description = "Whether the optional Secrets Manager read policy was created."
  value       = var.secret_arn != null
}