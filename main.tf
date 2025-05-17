provider "aws" {}

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  required_version = ">= 1.0.0"
  backend "s3" {
    bucket = "tfstate-storage-nirvana"
    key    = "xxxxxxxxxxxxxxxx.tfstate"
  }
}
