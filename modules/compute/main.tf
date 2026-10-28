data "aws_ssm_parameter" "al2023_ami" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}
resource "aws_launch_template" "app" {
  name_prefix   = "${var.project_name}-app-"
  image_id      = data.aws_ssm_parameter.al2023_ami.value
  instance_type = var.instance_type

  vpc_security_group_ids = [
    var.app_security_group_id
  ]

  # Require IMDSv2 for instance metadata access
  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  # Encrypted root volume
  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size           = 8
      volume_type           = "gp3"
      encrypted             = true
      delete_on_termination = true
    }
  }
  iam_instance_profile {
    name = var.iam_instance_profile_name
  }

  # Bootstrap a simple web application

  user_data = base64encode(<<-EOF
  #!/bin/bash
  set -euxo pipefail

  dnf install -y nginx

  cat > /usr/share/nginx/html/index.html <<'HTML'
  <!DOCTYPE html>
  <html lang="en">
  <head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>AWS 3-Tier Architecture</title>
  </head>
  <body>
    <h1>AWS 3-Tier Architecture</h1>
    <p>Nginx is running successfully!</p>
    <p>Provisioned using Terraform.</p>
  </body>
  </html>
  HTML

  systemctl enable --now nginx
EOF
  )

  tag_specifications {
    resource_type = "instance"

    tags = merge(var.tags, {
      Name = "${var.project_name}-app"
    })
  }

  tag_specifications {
    resource_type = "volume"

    tags = merge(var.tags, {
      Name = "${var.project_name}-app-volume"
    })
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-launch-template"
  })
}
resource "aws_autoscaling_group" "app" {
  name = "${var.project_name}-app-asg"

  min_size         = var.min_size
  desired_capacity = var.desired_capacity
  max_size         = var.max_size

  vpc_zone_identifier = var.private_subnet_ids

  target_group_arns = [
    var.target_group_arn
  ]

  health_check_type         = "ELB"
  health_check_grace_period = 180

  launch_template {
    id      = aws_launch_template.app.id
    version = tostring(aws_launch_template.app.latest_version)
  }

  dynamic "tag" {
    for_each = merge(var.tags, {
      Name = "${var.project_name}-app"
    })

    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

  lifecycle {
    ignore_changes = [
      desired_capacity
    ]
  }
}