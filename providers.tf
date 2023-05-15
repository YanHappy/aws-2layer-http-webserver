terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.66.1"
    }
  }
}
provider "aws" {
  shared_config_files      = ["/Users/cuong.huynh/.aws/config"]
  shared_credentials_files = ["/Users/cuong.huynh/.aws/credentials"]
  profile                  = "local"
  region                   = "ap-southeast-1"
}
