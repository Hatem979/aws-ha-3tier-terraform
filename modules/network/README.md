
# Network Module

Creates the networking foundation for the AWS
3-Tier Secure High Availability project.

## Resources

- Amazon VPC
- Public, private application, and private database subnets
- Internet Gateway
- Public and private route tables
- Optional NAT Gateways and Elastic IPs
- Route table associations

## Design

- Two Availability Zones
- Separate public, application, and database subnets
- Private subnets have no direct Internet Gateway route
- NAT Gateways are disabled by default to control costs

## Inputs

- `project_name`
- `vpc_cidr`
- `availability_zones`
- `public_subnet_cidrs`
- `private_app_subnet_cidrs`
- `private_db_subnet_cidrs`
- `enable_nat_gateway`
- `tags`

## Outputs

- `vpc_id`
- `public_subnet_ids`
- `private_app_subnet_ids`
- `private_db_subnet_ids`
- Route table IDs
- `nat_gateway_ids`

## Notes

This module creates networking resources only.
Security groups, application resources, database
resources, endpoints, and monitoring are managed
by separate modules.

NAT Gateways incur ongoing charges when created.
Review AWS account eligibility and estimated costs
before deployment.
### S3 Gateway Endpoint Architecture

To ensure secure, private, and cost-efficient communication between resources inside the private subnets (Application and Database tiers) and Amazon S3, an **AWS VPC Gateway Endpoint** is provisioned.

* **No Public Internet Traversal:** Traffic destined for S3 does not leave the AWS internal network backbone. It routes directly from the private route tables through the Gateway Endpoint without requiring a NAT Gateway or traversing the public internet.
* **Security & Compliance:** By eliminating internet exposure for internal S3 traffic, the architecture aligns with AWS Security Best Practices.
* **Cost Optimization:** Gateway Endpoints are entirely free of hourly charges and data-processing fees, making them ideal for high-throughput traffic between VPC resources and S3 buckets.