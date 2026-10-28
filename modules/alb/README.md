# Application Load Balancer (ALB) Module

## Overview

This Terraform module provisions an internet-facing **AWS Application Load Balancer (ALB)** to distribute incoming HTTP traffic across application EC2 instances deployed in private subnets.

The module separates the load-balancing layer from the compute layer, improving modularity, scalability, and maintainability.

## Architecture

The ALB is deployed in public subnets across two Availability Zones and forwards incoming requests to a target group containing application instances.

```text
                    Internet
                        |
                        v
              Application Load Balancer
                   (HTTP :80)
                        |
                        v
                  Target Group
                   (HTTP :80)
                        |
              +---------+---------+
              |                   |
              v                   v
       Private EC2 - AZ A   Private EC2 - AZ B
              |                   |
              +---------+---------+
                        |
                        v
                  Application Tier
```

## Resources Created

| Resource | Purpose |
|---|---|
| `aws_lb.alb` | Creates an internet-facing Application Load Balancer. |
| `aws_lb_target_group.app` | Defines the target group for application instances and configures health checks. |
| `aws_lb_listener.http` | Listens for HTTP requests on port 80 and forwards them to the target group. |

## Key Features

### 1. Internet-Facing Load Balancer

The ALB is configured with `internal = false` and deployed across public subnets.

It serves as the public entry point for incoming application traffic, while application instances remain in private subnets.

### 2. Target Group and Traffic Forwarding

The target group uses:
- **Protocol:** HTTP
- **Port:** 80
- **Target type:** Instance
- **VPC:** The VPC created by the network module

The HTTP listener forwards incoming requests to the target group, allowing the ALB to distribute traffic across registered application instances.

### 3. Health Checks

The target group performs HTTP health checks using the `/` path.

| Setting | Configuration |
|---|---|
| Protocol | HTTP |
| Health check path | `/` |
| Interval | 30 seconds |
| Timeout | 5 seconds |
| Success codes | `200–399` |

Health checks help the ALB identify application instances that are not responding as expected and avoid routing normal requests to unhealthy targets.

The health check configuration should match the application's actual health endpoint in a production environment.

### 4. Security Integration

The ALB uses a dedicated Security Group that allows inbound HTTP traffic on TCP port 80.

Its outbound rules permit traffic to the application tier on the configured application port.

The application Security Group accepts inbound traffic only from the ALB Security Group, preventing direct inbound access to the application instances through their Security Group rules.

### 5. High Availability

The module accepts a list of public subnet IDs and requires at least two subnets.

Deploying the ALB across subnets in different Availability Zones supports a highly available entry point, provided the selected Availability Zones and the rest of the architecture are configured correctly.

### 6. Configurable Health Checks and Ports

The module exposes configurable variables for:
- Application port
- Health check path
- Public subnet IDs
- ALB Security Group ID
- Project name and resource tags

This allows the module to be reused in different environments without hardcoding environment-specific values.

## Module Inputs

| Variable | Description |
|---|---|
| `project_name` | Project identifier used for resource naming. |
| `vpc_id` | ID of the VPC in which the target group is created. |
| `public_subnet_ids` | Public subnet IDs used by the ALB; at least two are required. |
| `alb_security_group_id` | Security Group attached to the ALB. |
| `target_port` | Port used by the application targets; defaults to `80`. |
| `health_check_path` | HTTP path used for target health checks; defaults to `/`. |
| `tags` | Tags applied to supported resources. |

## Module Outputs

| Output | Description |
|---|---|
| `alb_id` | ID of the Application Load Balancer. |
| `alb_arn` | ARN of the Application Load Balancer. |
| `alb_dns_name` | DNS name assigned to the ALB by AWS. |
| `target_group_arn` | ARN of the application target group. |
| `http_listener_arn` | ARN of the HTTP listener. |

## Traffic Flow

1. A client sends an HTTP request to the ALB DNS name.
2. The ALB listener receives the request on port 80.
3. The listener forwards the request to the target group.
4. The ALB selects a healthy registered application instance.
5. The application responds through the ALB to the client.

## Security Considerations

- Application instances are placed in private subnets and are not intended to be accessed directly from the internet.
- The application Security Group should allow inbound application traffic only from the ALB Security Group.
- The current implementation uses HTTP on port 80.
- For production workloads, configure an HTTPS listener using an AWS Certificate Manager (ACM) certificate and redirect HTTP traffic to HTTPS.
- Keep the ALB Security Group restricted to the intended listener ports.

**Important:** HTTPS encryption between the client and the ALB is not enabled by the current HTTP-only configuration.

## Deployment and Validation

Initialize and validate the Terraform configuration from the root environment:

```bash
terraform -chdir=environments/dev init
terraform -chdir=environments/dev validate
terraform -chdir=environments/dev plan
```

Review the plan and expected AWS charges before applying changes. An Application Load Balancer incurs charges while provisioned, so destroy temporary resources when they are no longer required.

## Design Rationale

The ALB module provides a dedicated entry point for the application, centralizes traffic distribution and health checks, and keeps the compute layer isolated from direct public inbound traffic.

Its modular implementation makes the architecture easier to maintain, extend, and reuse across environments.