data "aws_cloudfront_cache_policy" "test" {
  name = "Managed-CachingOptimized"
}

resource "aws_cloudfront_distribution" "test" {
  enabled             = true
  default_root_object = "index.html"

  origin {
    origin_id                = aws_s3_bucket.test.id
    domain_name              = aws_s3_bucket.test.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.test.id
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  default_cache_behavior {
    target_origin_id       = aws_s3_bucket.test.id
    viewer_protocol_policy = "redirect-to-https"
    cached_methods         = ["GET", "HEAD"]
    allowed_methods        = ["GET", "HEAD"]
    cache_policy_id        = data.aws_cloudfront_cache_policy.test.id
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = {
    Name = var.pj_name
  }
}

resource "aws_cloudfront_origin_access_control" "test" {
  name                              = aws_s3_bucket.test.bucket_domain_name
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

#############################################
# This resource is used to create a CloudWatch log delivery source for CloudFront
#############################################
resource "aws_s3_bucket" "cloudfront_logs" {
  bucket = "${var.pj_name}-obsidian-logs-cloudfront"
  tags   = {
    Name = var.pj_name
  }
  
}
resource "aws_cloudwatch_log_delivery_source" "test" {
  name         = "cloudfront-source"
  log_type     = "ACCESS_LOGS"
  resource_arn = aws_cloudfront_distribution.test.arn
}

resource "aws_cloudwatch_log_delivery_destination" "test" {
  name          = "s3-destination"
  output_format = "parquet"

  delivery_destination_configuration {
    destination_resource_arn = aws_s3_bucket.cloudfront_logs.arn
  }
}

resource "aws_cloudwatch_log_delivery" "test" {
  delivery_source_name     = aws_cloudwatch_log_delivery_source.test.name
  delivery_destination_arn = aws_cloudwatch_log_delivery_destination.test.arn

  s3_delivery_configuration {
    suffix_path = "/{DistributionId}/{yyyy}/{MM}/{dd}/{HH}"
  }
}