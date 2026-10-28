# IAM Module

## Overview

This module creates an AWS Identity and Access Management (IAM) Role and Instance Profile for EC2 instances in the application tier.

It follows the **Principle of Least Privilege**, ensuring that EC2 instances receive only the permissions required for their intended tasks.

The module also supports an optional IAM policy for accessing a specific AWS Secrets Manager secret when the application needs database credentials.

## Architecture

The module integrates with the Compute and Database modules:

- **IAM Role:** Defines the permissions available to EC2 instances.
- **Trust Policy:** Allows the EC2 service to assume the IAM Role.
- **IAM Instance Profile:** Makes the IAM Role available to EC2 instances through the Launch Template.
- **Optional Secrets Manager Policy:** Grants read access to a specific secret when an ARN is provided.

## Resources Created

| Resource | Purpose |
|---|---|
| `aws_iam_role` | Creates the IAM Role for EC2 instances. |
| `aws_iam_instance_profile` | Attaches the IAM Role to EC2 instances. |
| `aws_iam_role_policy` | Optionally grants access to a specific Secrets Manager secret. |

The Secrets Manager policy is created only when `secret_arn` is provided.

## Security Design

### 1. Least Privilege

The module does not grant broad permissions such as `secretsmanager:*` or access to all secrets in the AWS account.

When secret access is enabled, the policy permits only:

- `secretsmanager:GetSecretValue`
- `secretsmanager:DescribeSecret`

The resource is restricted to the specific secret ARN supplied to the module.

### 2. EC2 Trust Policy

The IAM Role trust policy specifies `ec2.amazonaws.com` as the trusted service and permits the `sts:AssumeRole` action.

This allows EC2 to assume the role without embedding long-term AWS access keys in the instance.

### 3. Instance Profile Integration

The Instance Profile is attached to the EC2 Launch Template in the Compute module. Instances launched through the Auto Scaling Group can therefore obtain temporary credentials through the EC2 instance metadata service.

### 4. Secrets Manager Integration

The Database module uses RDS-managed master credentials through:

`manage_master_user_password = true`

RDS manages the master password and stores it in AWS Secrets Manager.

The current Nginx demonstration application does not connect to the database, so the IAM module does not grant secret-reading permissions by default.

When the application requires database credentials, the secret ARN can be passed to this module.

If the secret uses a customer-managed AWS KMS key, additional narrowly scoped KMS permissions may be required.

## Inputs

| Name | Description | Required | Default |
|---|---|---|---|
| `project_name` | Project name used to identify IAM resources. | Yes | — |
| `secret_arn` | ARN of the specific Secrets Manager secret that EC2 may read. | No | `null` |
| `tags` | Common tags applied to supported IAM resources. | No | `{}` |

## Outputs

| Name | Description |
|---|---|
| `ec2_role_arn` | ARN of the EC2 IAM Role. |
| `ec2_role_name` | Name of the EC2 IAM Role. |
| `ec2_instance_profile_name` | Name of the Instance Profile attached to EC2. |
| `secret_read_policy_created` | Indicates whether the optional secret-reading policy is configured. |

## Root Module Integration

The IAM module is called from `environments/dev/main.tf`:

```hcl
module "iam" {
  source = "../../modules/iam"

  project_name = var.project_name
  secret_arn   = null

  tags = local.common_tags
}
```

The resulting Instance Profile name is passed to the Compute module:

```hcl
iam_instance_profile_name = module.iam.ec2_instance_profile_name
```

To enable access to the RDS-managed secret when required:

```hcl
secret_arn = module.database.master_user_secret_arn
```

Only enable this permission when the application actually needs it.

## Validation

Run the following commands from the root environment directory:

```bash
terraform fmt -recursive
terraform init
terraform validate
terraform plan
```

Review the plan before applying any infrastructure changes.

## Production Considerations

This module provides a basic IAM foundation for EC2 workloads. Before using it in production:

- Grant only the permissions required by the application.
- Avoid storing AWS access keys on EC2 instances.
- Require IMDSv2 in the Launch Template.
- Restrict secret access to the intended application and secret.
- Review KMS permissions when customer-managed keys are used.
- Consider separate IAM roles for workloads with different access requirements.
- Review IAM changes through Terraform plans and version control.

## Limitations

This module does not automatically retrieve secrets inside the application, configure database connectivity, or establish a database connection. Those behaviors must be implemented and tested separately.

It also does not create the RDS-managed secret; the Database module configures RDS to manage its master credentials.
