resource "aws_s3_bucket" "test" {
  bucket = "${var.pj_name}-obsidian"
  tags = {
    Name = var.pj_name
  }
  force_destroy = true
}

resource "aws_s3_object" "test" {
  bucket       = aws_s3_bucket.test.id
  key          = "index.html"
  source       = "./index.html"
  content_type = "text/html"
}

data "aws_iam_policy_document" "s3" {
  #   statement {
  #     effect = "Deny"
  #     principals {
  #       type        = "AWS"
  #       identifiers = ["*"]
  #     }
  #     actions = [
  #       "s3:GetObject"
  #     ]
  #     resources = [
  #       "${aws_s3_bucket.test.arn}/*"
  #     ]
  #     condition {
  #       test     = "NotIpAddress"
  #       variable = "aws:SourceIp"
  #       values = var.source_ip_address_list
  #     }
  #   }
  statement {
    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }
    actions = [
      "s3:GetObject"
    ]
    resources = [
      "${aws_s3_bucket.test.arn}/*"
    ]
    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"
      values = [
        aws_cloudfront_distribution.test.arn,
      ]
    }
  }
}

resource "aws_s3_bucket_policy" "test" {
  bucket = aws_s3_bucket.test.id
  policy = data.aws_iam_policy_document.s3.json
}

###########################################
# S3 Bucket Logging
###########################################

resource "aws_s3_bucket" "logs" {
  bucket = "${var.pj_name}-obsidian-logs"
  tags = {
    Name = var.pj_name
  }
  force_destroy = true

}

resource "aws_s3_bucket_logging" "test" {
  bucket        = aws_s3_bucket.test.id
  target_bucket = aws_s3_bucket.logs.id
  target_prefix = ""

}

data "aws_iam_policy_document" "s3_logging" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["logging.s3.amazonaws.com"]
    }
    actions = [
      "s3:PutObject",
    ]
    resources = [
      "${aws_s3_bucket.logs.arn}/logs/*"
    ]
    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values   = [aws_s3_bucket.test.arn]
    }
    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [data.aws_caller_identity.current.id]
    }
  }
}
resource "aws_s3_bucket_policy" "logs" {
  bucket = aws_s3_bucket.logs.id
  policy = data.aws_iam_policy_document.s3_logging.json
}

resource "aws_s3_bucket_lifecycle_configuration" "logs" {
  bucket = aws_s3_bucket.logs.id
  rule {
    id     = "log-expiration"
    status = "Enabled"

    expiration {
      days = 7
    }
  }
}