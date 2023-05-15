module "app_security_group" {
  source      = "terraform-aws-modules/security-group/aws"
  version     = "4.17.1"
  name        = "web-server-sg"
  description = "Security group for web-servers with HTTP ports open within VPC"
  vpc_id      = module.vpc.vpc_id

  ingress_with_source_security_group_id = [
    {
      #allow http request to loadbalancer
      rule                     = "http-80-tcp"
      source_security_group_id = module.lb_security_group.security_group_id
    },
  ]

  egress_with_cidr_blocks = [
    {
      rule        = "all-all"
      cidr_blocks = "0.0.0.0/0"
    },
  ]
  depends_on = [module.lb_security_group]
}

module "lb_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.17.1"

  name = "load-balancer-sg"

  description = "Security group for load balancer with HTTP ports open within VPC"
  vpc_id      = module.vpc.vpc_id

  ingress_with_cidr_blocks = [
    {
      rule        = "http-80-tcp"
      cidr_blocks = "0.0.0.0/0"
    },
  ]

  egress_with_cidr_blocks = [
    {
      rule        = "all-all"
      cidr_blocks = "0.0.0.0/0"
    },
  ]
}