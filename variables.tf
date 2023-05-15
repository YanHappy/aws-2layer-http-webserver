variable "aws_region" {
  description = "AWS region to launch servers."
  default     = "ap-southeast-1"
}

# Ubuntu Precise 12.04 LTS (x64)
variable "aws_amis" {
  default = {
    ap-southeast-1 = "ami-0a72af05d27b49ccb"
  }
}

variable "instance_count" {
  description = "Number of instance in each AZ"
  type        = number
  default     = 1
}

variable "instance_type" {
  description = "Type of EC2 instance"
  type        = string
  default     = "t2.micro"
}