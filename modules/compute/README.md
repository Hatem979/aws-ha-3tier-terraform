# Compute Module

## Overview

The Compute Module provisions and manages the application compute layer using Amazon EC2, an EC2 Launch Template, and an Auto Scaling Group (ASG).

It deploys application instances in private subnets across multiple Availability Zones and registers them with the Application Load Balancer (ALB) target group.

The module is designed to support scalability, availability, repeatable instance configuration, and infrastructure management through Terraform.

## Architecture

```text
              Application Load Balancer
                          |
                          v
                     Target Group
                          |
                 Auto Scaling Group
                          |
              +-----------+-----------+
              |                       |
              v                       v
       EC2 Instance - AZ A      EC2 Instance - AZ B
              |                       |
              +-----------+-----------+
                          |
                  Nginx Web Server
```

## Resources Created

| Resource | Purpose |
|---|---|
| `data.aws_ssm_parameter.al2023_ami` | Retrieves the latest Amazon Linux 2023 AMI ID from AWS Systems Manager Parameter Store. |
| `aws_launch_template.app` | Defines the AMI, instance type, Security Group, storage configuration, metadata options, and bootstrap script. |
| `aws_autoscaling_group.app` | Maintains the desired number of EC2 instances and integrates them with the ALB target group. |

## Key Features

### 1. EC2 Launch Template

The Launch Template defines a consistent configuration for all application instances.

The current configuration includes:

- **Operating system:** Amazon Linux 2023.
- **Instance type:** `t3.micro` by default.
- **AMI selection:** Retrieved dynamically through AWS Systems Manager Parameter Store.
- **Network security:** Uses the application Security Group.
- **Instance metadata:** Requires IMDSv2.
- **Root storage:** 8 GiB encrypted `gp3` EBS volume.
- **Bootstrap configuration:** Installs and starts Nginx and creates a sample HTML page.

Using a Launch Template makes it easier to apply consistent configurations when the Auto Scaling Group launches new instances.

### 2. Automatic Nginx Installation

The EC2 User Data script automates the initial application setup.

During instance initialization, the script:

1. Installs Nginx using the Amazon Linux package manager (`dnf`).
2. Creates a custom HTML page in `/usr/share/nginx/html/index.html`.
3. Enables and starts the Nginx service.

This demonstrates infrastructure bootstrapping without requiring manual SSH access to configure every instance.

**Networking requirement:** Installing Nginx from public package repositories requires outbound connectivity. With private instances, this normally means configuring a NAT Gateway or an alternative package-delivery mechanism.

If NAT is disabled and no alternative egress path exists, the package installation can fail.

### 3. Auto Scaling Group

The Auto Scaling Group manages the application instances according to the configured capacity settings.

| Setting | Default configuration |
|---|---|
| Minimum capacity | 2 instances |
| Desired capacity | 2 instances |
| Maximum capacity | 4 instances |
| Health check type | ELB |
| Health check grace period | 180 seconds |
| Subnets | Private application subnets |
| Load balancing integration | ALB target group |

The group distributes instances across the supplied private subnet IDs, allowing deployment across multiple Availability Zones.

The ELB health check configuration helps the Auto Scaling Group identify instances considered unhealthy by the load balancer.

The group can replace unhealthy instances, while its maximum capacity defines the upper limit for the number of instances it may maintain.

**Note:** Configuring a maximum capacity of four does not automatically enable CPU-based or request-based scaling policies. Those require additional scaling policies and CloudWatch metrics or target tracking.

### 4. Private Subnet Deployment

Application instances are deployed in private application subnets rather than public subnets.

The instances do not require public IP addresses for the intended architecture. Incoming HTTP traffic is expected to arrive through the ALB.

The application Security Group should permit inbound application traffic only from the ALB Security Group.

This reduces direct internet exposure and separates the public entry point from the application compute layer.

### 5. Instance Security

The Launch Template incorporates security-focused configuration:

- IMDSv2 is required to access instance metadata.
- The root EBS volume is encrypted.
- Application instances use a dedicated Security Group.
- Instances are deployed in private subnets.
- Nginx is configured through User Data for repeatable provisioning.

For a production deployment, consider adding an IAM instance profile with least-privilege permissions, centralized logging, patch management, and controlled administrative access through AWS Systems Manager Session Manager.

### 6. Terraform Lifecycle Management

The Auto Scaling Group uses a lifecycle rule to ignore changes to `desired_capacity`.

This can prevent Terraform from repeatedly resetting the desired instance count when the capacity is changed outside Terraform.

However, this behavior also means Terraform may not restore the configured desired capacity automatically after an external change. Use this setting intentionally and document which system is responsible for managing capacity.

## Module Inputs

| Variable | Description |
|---|---|
| `project_name` | Project identifier used for resource naming. |
| `private_subnet_ids` | Private application subnet IDs used by the Auto Scaling Group. |
| `app_security_group_id` | Security Group attached to application instances. |
| `target_group_arn` | ARN of the ALB target group receiving application traffic. |
| `instance_type` | EC2 instance type; defaults to `t3.micro`. |
| `min_size` | Minimum number of instances; defaults to `2`. |
| `desired_capacity` | Desired number of instances; defaults to `2`. |
| `max_size` | Maximum number of instances; defaults to `4`. |
| `tags` | Tags applied to supported resources. |

## Module Outputs

| Output | Description |
|---|---|
| `launch_template_id` | ID of the EC2 Launch Template. |
| `autoscaling_group_name` | Name of the Auto Scaling Group. |

## Application Request Flow

1. A client sends an HTTP request to the Application Load Balancer.
2. The ALB forwards the request to a healthy registered target.
3. The selected EC2 instance receives the request on the application port.
4. Nginx serves the sample HTML page.
5. The response returns to the client through the ALB.

## Validation and Deployment

Run the following commands from the project root to initialize, validate, and review the Terraform configuration:

```bash
terraform -chdir=environments/dev init
terraform -chdir=environments/dev validate
terraform -chdir=environments/dev plan
```

Review the plan before deployment and verify that the selected AMI, instance configuration, subnet placement, and target group integration are correct.

EC2 instances, EBS volumes, and associated networking resources can incur charges. Review AWS pricing and the estimated deployment cost before applying changes.

## Design Rationale

This module separates compute provisioning from networking, security, and load balancing.

Combining Launch Templates with an Auto Scaling Group provides repeatable instance configuration and a foundation for high availability and future scaling policies.

The module can be extended with CPU-based scaling, instance refresh, Systems Manager management, centralized logging, and HTTPS-enabled application delivery as the architecture evolves.