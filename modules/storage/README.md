# S3 Storage Module

## Overview

This module provisions a private Amazon S3 bucket for application files in the AWS 3-Tier Secure High Availability Architecture.

The bucket is designed to integrate with Amazon CloudFront using Origin Access Control (OAC), allowing content delivery without making the bucket publicly accessible.

## Architecture

The storage layer is designed to work with the CloudFront distribution:

- Amazon S3 stores application files.
- S3 Block Public Access prevents unintended public exposure.
- CloudFront OAC will provide controlled access to the S3 origin.
- Bucket policies restrict access according to the intended security model.

The CloudFront integration and its bucket-specific permissions are configured in the CDN integration stage.

## Resources Created

| Resource | Purpose |
|---|---|
| `aws_s3_bucket` | Creates the private S3 bucket. |
| `aws_s3_bucket_ownership_controls` | Enforces bucket-owner ownership and disables ACLs. |
| `aws_s3_bucket_public_access_block` | Blocks public access through ACLs and bucket policies. |
| `aws_s3_bucket_versioning` | Enables object versioning. |
| `aws_s3_bucket_server_side_encryption_configuration` | Enables default SSE-S3 encryption. |
| `aws_s3_bucket_policy` | Denies requests made without secure transport. |

## Security Configuration

### 1. Block Public Access

All four S3 Block Public Access settings are enabled.

This helps prevent accidental public exposure of objects and bucket policies.

### 2. Object Ownership

The bucket uses `BucketOwnerEnforced`, disabling ACLs and relying on IAM policies and bucket policies for access control.

### 3. Encryption at Rest

Default server-side encryption uses SSE-S3 (`AES256`).

This provides encryption at rest without requiring a customer-managed KMS key.

A customer-managed AWS KMS key may be considered if additional key-management controls or compliance requirements justify the additional complexity and cost.

### 4. Versioning

S3 Versioning is enabled to support recovery from accidental overwrites and deletions.

Versioning does not replace backups or lifecycle management. Retained object versions can increase storage costs, so lifecycle policies should be considered based on retention requirements.

### 5. Secure Transport

The bucket policy denies S3 requests that do not use HTTPS.

This policy does not grant public access or grant CloudFront permission to read objects.

### 6. CloudFront Integration

The intended integration uses CloudFront Origin Access Control (OAC).

The CloudFront module will provide the appropriate S3 bucket permission for the intended distribution. The bucket remains private.

## Inputs

| Name | Description | Required | Default |
|---|---|---|---|
| `project_name` | Project name used for resource identification. | Yes | — |
| `bucket_name` | Globally unique S3 bucket name. | Yes | — |
| `tags` | Common resource tags. | No | `{}` |

## Outputs

| Name | Description |
|---|---|
| `bucket_id` | S3 bucket name. |
| `bucket_arn` | S3 bucket ARN. |
| `bucket_regional_domain_name` | Regional S3 endpoint for CloudFront origin configuration. |
| `bucket_hosted_zone_id` | Route 53 hosted zone ID associated with the S3 endpoint. |

## Root Module Integration

The storage module is called from `environments/dev/main.tf`:

```hcl
module "storage" {
  source = "../../modules/storage"

  project_name = var.project_name
  bucket_name  = var.s3_bucket_name

  tags = local.common_tags
}
```

The bucket name is provided through the root environment variables.

## Validation

Run the following commands from the environment directory:

```bash
terraform fmt -recursive
terraform validate
terraform plan
```

Review the plan before deploying any resources.

## Cost Considerations

Potential costs include:

- S3 storage.
- Requests to upload, retrieve, and manage objects.
- Retained object versions.
- Data transfer.
- Optional lifecycle transitions and related requests.

The exact cost depends on storage volume, request volume, region, and the selected storage classes.

## Cleanup Considerations

The bucket is configured with `force_destroy = false`, which helps prevent Terraform from automatically deleting a non-empty bucket.

Before destroying the development environment, review and remove its objects and retained versions according to the intended cleanup process.

## Limitations

This module does not configure file uploads, application-level access, CORS, lifecycle policies, or CloudFront OAC permissions.

Those features should be added only when the application's access and retention requirements are defined.
