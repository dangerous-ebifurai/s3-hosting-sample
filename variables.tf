variable "pj_name" {
  description = "The name of the project"
  type        = string
  default     = "s3-hosting-sample"
}

variable "source_ip_address_list" {
  description = "The source IP address list for the S3 bucket policy"
  type        = list(string)
  sensitive   = true
}