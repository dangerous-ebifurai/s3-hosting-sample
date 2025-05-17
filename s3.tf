resource "aws_s3_bucket" "test" {
  bucket = var.pj_name
  tags = {
    Name = var.pj_name
  }
}