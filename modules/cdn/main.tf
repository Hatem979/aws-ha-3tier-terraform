
# --------------------------------------------------
# S3 Origin Access Control
# --------------------------------------------------

resource "aws_cloudfront_origin_access_control" "s3" {
  name                              = "${var.project_name}-s3-oac"
  description                       = "Secure access from CloudFront to the private S3 bucket"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# --------------------------------------------------
# CloudFront Distribution
# --------------------------------------------------

resource "aws_cloudfront_distribution" "cdn" {
  enabled         = true
  is_ipv6_enabled = true
  web_acl_id      = var.waf_web_acl_arn
  comment         = "${var.project_name} CDN"
  price_class     = "PriceClass_100"

  # Dynamic application origin
  origin {
    domain_name = var.alb_dns_name
    origin_id   = "app-alb-origin"
    custom_header {
      name  = "X-Origin-Verify"
      value = var.origin_verify_header_value
    }
    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]

    }
  }

  # Private S3 origin for static assets
  origin {
    domain_name              = var.s3_bucket_regional_domain_name
    origin_id                = "private-s3-origin"
    origin_access_control_id = aws_cloudfront_origin_access_control.s3.id
  }

  # Default behavior: dynamic application requests go to ALB
  default_cache_behavior {
    target_origin_id       = "app-alb-origin"
    viewer_protocol_policy = "redirect-to-https"

    allowed_methods = [
      "DELETE",
      "GET",
      "HEAD",
      "OPTIONS",
      "PATCH",
      "POST",
      "PUT"
    ]

    cached_methods = ["GET", "HEAD"]

    # Managed policy: CachingDisabled
    cache_policy_id = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad"

    # Forward viewer headers/cookies/query strings except Host
    origin_request_policy_id = "b689b0a8-53d0-40ab-baf2-68738e2966ac"

    compress = true
  }

  # Static assets: /assets/* go to S3
  ordered_cache_behavior {
    path_pattern           = "/assets/*"
    target_origin_id       = "private-s3-origin"
    viewer_protocol_policy = "redirect-to-https"

    allowed_methods = ["GET", "HEAD", "OPTIONS"]
    cached_methods  = ["GET", "HEAD", "OPTIONS"]

    # Managed policy: CachingOptimized
    cache_policy_id = "658327ea-f89d-4fab-a63d-7e88639e58f6"

    compress = true
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  tags = merge(var.tags, {
    Name      = "${var.project_name}-cdn"
    Component = "cdn"
  })
}

# --------------------------------------------------
# S3 Bucket Policy
# --------------------------------------------------

data "aws_caller_identity" "current" {}

resource "aws_s3_bucket_policy" "cloudfront_access" {
  bucket = var.s3_bucket_id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid       = "DenyInsecureTransport"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"

        Resource = [
          var.s3_bucket_arn,
          "${var.s3_bucket_arn}/*"
        ]

        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
      },
      {
        Sid    = "AllowCloudFrontReadOnly"
        Effect = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }

        Action   = "s3:GetObject"
        Resource = "${var.s3_bucket_arn}/*"

        Condition = {
          StringEquals = {
            "AWS:SourceArn"     = aws_cloudfront_distribution.cdn.arn
            "AWS:SourceAccount" = data.aws_caller_identity.current.account_id
          }
        }
      }
    ]
  })
}
