# Development Environment — AWS 3-Tier Architecture

## Overview

This directory contains the root Terraform configuration for deploying the development environment of the AWS 3-Tier Secure High Availability Architecture.

It composes reusable Terraform modules to provision the network, security controls, load balancing, application compute layer, relational database, and IAM configuration.

The infrastructure is designed to demonstrate Infrastructure as Code (IaC), modular Terraform design, network segmentation, high availability concepts, and security best practices.

## Architecture

The environment consists of three logical tiers:

### 1. Presentation Tier

- Application Load Balancer (ALB)
- Public subnets across two Availability Zones
- HTTP listener forwarding requests to the application target group

### 2. Application Tier

- Amazon EC2 instances managed by an Auto Scaling Group
- Private application subnets across two Availability Zones
- Launch Template with Amazon Linux 2023
- Nginx installed through EC2 user data
- IAM Instance Profile for workload identity
- Security Group allowing application traffic only from the ALB

### 3. Database Tier

- Amazon RDS for MySQL
- Private database subnets
- DB subnet group spanning two Availability Zones
- Storage encryption and automated backups
- RDS-managed master credentials stored in AWS Secrets Manager
- Security Group permitting MySQL traffic only from the application tier

The actual availability and resilience characteristics depend on the selected resource configuration, including the RDS Multi-AZ setting and Auto Scaling Group capacity.

## Terraform Module Structure

The root configuration composes the following modules:

| Module | Responsibility |
|---|---|
| `network` | VPC, public and private subnets, routing, Internet Gateway, and optional NAT Gateways |
| `security` | Security Groups and tier-specific traffic restrictions |
| `alb` | Application Load Balancer, target group, and HTTP listener |
| `compute` | EC2 Launch Template and Auto Scaling Group |
| `database` | RDS MySQL instance, DB subnet group, and database outputs |
| `iam` | EC2 IAM Role, Instance Profile, and optional Secrets Manager access policy |
| `monitoring` | CloudWatch alarms, dashboard, and SNS notifications, if enabled in the root configuration |

## Deployment Flow

The root module connects the resources through Terraform outputs and inputs.

1. The Network module creates the VPC and subnet infrastructure.
2. The Security module creates Security Groups using the VPC ID.
3. The ALB module creates the load balancer and target group.
4. The Compute module creates the Launch Template and Auto Scaling Group using private application subnets and the target group.
5. The Database module creates the RDS instance in private database subnets.
6. The IAM module supplies an Instance Profile to the Compute module.
7. The Monitoring module, if configured, consumes resource identifiers to create alarms and dashboards.

Terraform infers dependencies from references between module inputs and outputs.

## Network Design

The VPC uses the CIDR range `10.0.0.0/16` and is configured for two Availability Zones in `us-east-1`.

| Subnet Tier | CIDR Blocks |
|---|---|
| Public | `10.0.1.0/24`, `10.0.2.0/24` |
| Private Application | `10.0.11.0/24`, `10.0.12.0/24` |
| Private Database | `10.0.21.0/24`, `10.0.22.0/24` |

Public subnets host the Application Load Balancer. Application instances and the database are placed in private subnets.

NAT Gateway deployment is controlled through the `enable_nat_gateway` variable. When NAT is disabled, private instances may not have outbound Internet access to download packages unless another egress path is configured.

For production deployments, NAT Gateway placement and routing should be designed according to availability, resilience, security, and cost requirements. A NAT Gateway per Availability Zone can reduce cross-AZ dependency, but increases cost.

## Security Considerations

- EC2 instances are deployed in private application subnets.
- The RDS instance is configured as non-publicly accessible.
- The application Security Group accepts HTTP traffic only from the ALB Security Group.
- The database Security Group accepts MySQL traffic only from the application Security Group.
- The EC2 Launch Template uses an IAM Instance Profile rather than embedded AWS access keys.
- The IAM module does not grant Secrets Manager read permissions unless a specific secret ARN is supplied.
- RDS master credentials are managed by RDS and stored in Secrets Manager.
- EC2 metadata access should require IMDSv2.
- The current ALB configuration uses HTTP. HTTPS requires an appropriate TLS certificate and listener configuration.

The current Nginx sample application does not automatically retrieve database credentials or establish a database connection.

## Prerequisites

Before deploying this environment, ensure that you have:

- An AWS account with the required service permissions.
- AWS CLI configured with an appropriate identity.
- Terraform installed.
- An AWS provider configuration with the intended region.
- An available service quota for the requested resources.

Use a dedicated development account or appropriately restricted credentials whenever possible.

## Configuration

Review the Terraform variable files before deployment.

The configuration includes settings such as:

- `project_name`
- `enable_nat_gateway`
- AWS region
- Resource tags
- Instance and database sizing
- Auto Scaling Group capacity
- RDS Multi-AZ configuration

Keep account-specific values in local variable files or environment variables as appropriate. Do not commit access keys, passwords, Terraform state files, or other sensitive data to GitHub.

## Validation and Deployment

Run the following commands from this directory.

### 1. Format the configuration

```bash
terraform fmt -recursive
```

### 2. Initialize Terraform

```bash
terraform init
```

### 3. Validate the configuration

```bash
terraform validate
```

### 4. Review the execution plan

```bash
terraform plan
```

Inspect the plan for unexpected resource changes, destructive actions, and configuration differences before proceeding.

### 5. Deploy the infrastructure

```bash
terraform apply
```

Review the final plan and confirm the operation only when you are ready to provision the resources.

### 6. Inspect the outputs

```bash
terraform output
```

Use the ALB DNS name output to test the application endpoint after deployment and verify target health in the AWS console.

Do not expose sensitive output values in screenshots, terminal recordings, or public documentation.

## Cost Management

This project can create billable AWS resources, including:

- Application Load Balancer
- NAT Gateways and their data processing
- EC2 instances
- Amazon RDS, including additional costs associated with Multi-AZ
- CloudWatch metrics, alarms, logs, and dashboards where applicable
- Secrets Manager secret storage and API usage

A successful Terraform plan does not guarantee that the deployment is within a particular budget. Review current AWS pricing and available account credits before applying.

For a short-lived portfolio demonstration, deploy only when needed and destroy the environment after completing testing and collecting non-sensitive evidence.

## Cleanup

After testing, review the resources managed by this Terraform configuration and remove the temporary environment:

```bash
terraform plan -destroy
terraform destroy
```

Review the proposed destruction before confirming it.

Ensure that any resources created outside this Terraform state are also accounted for. Terraform-managed state should be preserved until cleanup has been verified.

## Limitations and Future Improvements

Potential future enhancements include:

- HTTPS listener with ACM certificate
- AWS Systems Manager Session Manager for administrative access
- More advanced CloudWatch alarms and notification routing
- Application-level integration with RDS and Secrets Manager
- Remote Terraform state with locking and appropriate access controls
- CI/CD validation and deployment workflows
- Cost estimation and automated cleanup safeguards
- Further hardening of IAM permissions and production deletion safeguards

## Project Status

Terraform configuration validation and planning have completed successfully.

Successful validation and planning do not, by themselves, confirm that the infrastructure has been deployed or that application connectivity and high availability have been tested. Those checks should be documented after deployment and verification.
