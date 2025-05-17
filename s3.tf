resource "aws_s3_bucket" "test" {
  bucket = "${var.pj_name}-obsidian"
  tags = {
    Name = var.pj_name
  }
}

resource "aws_s3_bucket_public_access_block" "test" {
  bucket                  = aws_s3_bucket.test.id
  block_public_acls       = true
  ignore_public_acls      = true
  restrict_public_buckets = true
  block_public_policy     = true

}

resource "aws_s3_object" "test" {
  bucket       = aws_s3_bucket.test.id
  key          = "index.html"
  source       = "./index.html"
  content_type = "text/html"
}

data "aws_iam_policy_document" "s3" {
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
    condition {
      test     = "IpAddress"
      variable = "aws:SourceIp"
      values = [
        var.sour_ip_address,
      ]
    }
  }
}

resource "aws_s3_bucket_policy" "test" {
  bucket = aws_s3_bucket.test.id
  policy = data.aws_iam_policy_document.s3.json
}