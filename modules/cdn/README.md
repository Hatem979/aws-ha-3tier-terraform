# CloudFront CDN Module

## Overview

This Terraform module provisions an Amazon CloudFront distribution in front of an Application Load Balancer (ALB) and a private Amazon S3 bucket.

It separates dynamic application traffic from static asset delivery while keeping the S3 bucket private.

## Architecture

The distribution uses two origins:

- **ALB Origin:** Handles dynamic application requests and forwards them to the application tier.
- **S3 Origin:** Stores static assets such as images, CSS, and JavaScript files.

### Request Routing

| Path pattern | Origin | Caching |
|---|---|---|
| `/assets/*` | Private S3 bucket | CloudFront managed CachingOptimized policy |
| `/*` (default behavior) | Application Load Balancer | Caching disabled |

The application behavior forwards supported HTTP methods to the ALB. Only GET and HEAD responses are configured as cacheable methods.

The `/assets/*` behavior assumes static files are uploaded to the corresponding S3 object keys. The application must reference these paths correctly.

## Security Controls

- HTTPS is enforced for viewers through CloudFront's redirect-to-HTTPS policy.
- The default CloudFront certificate is used for the initial implementation.
- S3 Block Public Access remains enabled.
- S3 Object Ownership is configured as BucketOwnerEnforced in the Storage module.
- Origin Access Control (OAC) signs CloudFront-to-S3 requests using AWS Signature Version 4.
- The S3 bucket policy grants `s3:GetObject` to the CloudFront service principal only when the request originates from this distribution.
- Insecure S3 transport is explicitly denied.

## Current Limitations

- The ALB origin currently uses HTTP. Viewer HTTPS does not mean that traffic is encrypted between CloudFront and the ALB.
- The ALB is still publicly reachable directly unless additional origin restrictions are implemented. Direct ALB requests can bypass CloudFront-level protections, including a future AWS WAF configuration.
- A custom domain and its ACM certificate are not configured. The default CloudFront domain is used.
- The `/assets/*` route requires matching S3 objects to return actual static content.

These limitations are documented so that the next iteration can add HTTPS to the ALB, restrict direct origin access, configure AWS WAF, and support a custom domain.

## Cost Considerations

CloudFront may incur charges for data transfer and requests. Review the AWS pricing model and free-tier eligibility before deployment.

The distribution uses `PriceClass_100` to limit edge locations to the lower-cost price class. This is a cost-control choice, not a security control.

## Deployment and Cleanup

Run Terraform from the root environment directory:

```bash
terraform init
terraform fmt -recursive
terraform validate
terraform plan
```

Review the plan before applying any changes.

After testing, destroy disposable project resources and verify that no billable resources remain. S3 objects and bucket version history must be handled according to the Storage module's cleanup design.

## Future Improvements

- Attach AWS WAF with managed rule groups and rate limiting.
- Restrict direct access to the ALB origin.
- Configure HTTPS between CloudFront and the ALB.
- Add a custom domain and ACM certificates.
- Review caching policies against the application's real content and security requirements.
