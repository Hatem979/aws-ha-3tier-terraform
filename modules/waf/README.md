# AWS WAF Module

## Overview

This module provisions an AWS WAFv2 Web ACL intended to protect the project's Amazon CloudFront distribution.

The Web ACL uses AWS-managed rule groups for common web attacks and a rate-based rule to limit excessive requests from individual IP addresses.

## Security Rules

| Rule | Purpose | Initial action |
|---|---|---|
| AWSManagedCommonRules | Detect common web exploits | Count |
| AWSManagedKnownBadInputs | Detect known malicious input patterns | Count |
| AWSManagedSQLiRules | Detect SQL injection patterns | Count |
| IPRateLimit | Limit excessive requests from one IP | Block |

The managed rule groups initially use Count mode to observe traffic and reduce the risk of false positives. Count mode does not block matching requests.

The rate-based rule blocks requests when the configured threshold is exceeded. AWS WAF evaluates rates over a five-minute window; enforcement is not necessarily instantaneous.

## CloudFront Integration

The Web ACL uses `scope = "CLOUDFRONT"` and is associated with the CloudFront distribution through its `web_acl_id` argument.

CloudFront-scoped WAF resources must be managed through the US East (N. Virginia) region (`us-east-1`). Ensure the Terraform AWS provider for this resource uses that region.

## Monitoring

CloudWatch metrics and sampled requests are enabled for each rule. Review the metrics and sampled requests before switching managed rules from Count to Block.

Sampled requests can contain sensitive request data. Access to WAF and CloudWatch monitoring should be restricted appropriately.

## Important Limitations

- WAF protects requests that pass through the associated CloudFront distribution.
- Direct access to the public ALB can bypass CloudFront and its WAF rules until the ALB origin is restricted.
- Rate limiting is not a complete DDoS mitigation strategy.
- Managed rules and rate-based protections may incur additional AWS charges.

## Deployment

Run the following commands from the root environment directory:

```bash
terraform fmt -recursive
terraform init
terraform validate
terraform plan
```

Review the plan and cost implications before applying changes.

## Future Improvements

- Review WAF metrics and move appropriate managed rules to Block mode.
- Restrict direct access to the ALB origin.
- Configure end-to-end HTTPS to the ALB.
- Tune the rate limit based on legitimate application traffic.
- Consider additional AWS-managed rule groups if justified by the application's threat model.
