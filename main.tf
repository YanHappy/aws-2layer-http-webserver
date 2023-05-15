data "aws_availability_zones" "cuong_az" {
  state = "available"
}
resource "aws_vpc" "cuong_vpc" {
  cidr_block = "10.0.0.0/16"
}
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.14.2"

  cidr = "10.0.0.0/16"
  name = "VPC-Example"

  azs             = data.aws_availability_zones.cuong_az.names
  private_subnets = ["10.0.101.0/24", "10.0.102.0/24"]
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]

  enable_nat_gateway = true
  enable_vpn_gateway = false

  map_public_ip_on_launch = false
}

resource "aws_internet_gateway" "cuong_internet_gateway" {
  vpc_id = aws_vpc.cuong_vpc.id
}


resource "aws_route" "cuong_internet_access" {
  route_table_id         = aws_vpc.cuong_vpc.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.cuong_internet_gateway.id
}

#resource "aws_subnet" "cuong_subnet" {
#  count      = "${length(data.aws_availability_zones.cuong_az.names)}"
#  availability_zone       = "${data.aws_availability_zones.cuong_az.names[count.index]}"
#  vpc_id                  = "${aws_vpc.cuong_vpc.id}"
#  cidr_block              = "10.0.1.0/24"
#  map_public_ip_on_launch = true
#}

module "elb_http" {
  source  = "terraform-aws-modules/elb/aws"
  version = "3.0.1"

  # Comply with ELB name restrictions
  # https://docs.aws.amazon.com/elasticloadbalancing/2012-06-01/APIReference/API_CreateLoadBalancer.html
  name     = "example-application-ALB"
  internal = false

  security_groups = [module.lb_security_group.security_group_id]
  subnets         = module.vpc.public_subnets

  number_of_instances = length(module.ec2_instances.instance_ids)
  instances           = module.ec2_instances.instance_ids
  listener = [{
    instance_port     = "80"
    instance_protocol = "HTTP"
    lb_port           = "80"
    lb_protocol       = "HTTP"
  }]

  health_check = {
    target              = "HTTP:80/index.html"
    interval            = 10
    healthy_threshold   = 3
    unhealthy_threshold = 10
    timeout             = 5
  }
}

module "ec2_instances" {
  source     = "./modules/aws-instance"
  depends_on = [module.vpc, module.app_security_group]

  instance_count     = var.instance_count * length(module.vpc.private_subnets)
  instance_type      = var.instance_type
  subnet_ids         = module.vpc.private_subnets[*]
  security_group_ids = [module.app_security_group.security_group_id]
  Name               = "EC2-example-project"
}

