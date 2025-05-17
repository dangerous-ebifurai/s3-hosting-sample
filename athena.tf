# resource "aws_athena_database" "cloudfront_logs" {
#   name   = "cloudfront_logs"
#   bucket = aws_s3_bucket.cloudfront_logs.id
# }
# resource "aws_athena_workgroup" "cloudfront_logs" {
#   name        = "cloudfront_logs"
#   tags = {
#     Name = var.pj_name
#   }
# }
# resource "aws_athena_named_query" "cloudfront_logs" {
#   name      = "cloudfront_logs"
#   workgroup = aws_athena_workgroup.cloudfront_logs.id
#   database  = aws_athena_database.cloudfront_logs.name
#   query     = "SELECT * FROM ${aws_athena_database.cloudfront_logs.name} limit 10;"
# }
