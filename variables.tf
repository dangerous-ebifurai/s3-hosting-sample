variable "pj_name" {
  description = "The name of the project"
  type        = string
  default     = "s3-hosting-sample"
}

variable "sour_ip_address" {
  description = "The source IP address for the S3 bucket policy"
  type        = string
  sensitive = true  
}