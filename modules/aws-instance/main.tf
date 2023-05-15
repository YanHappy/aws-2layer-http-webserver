data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_instance" "app" {
  count = var.instance_count
  ami           = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type
  subnet_id              = var.subnet_ids[count.index % length(var.subnet_ids)]
  vpc_security_group_ids = var.security_group_ids
  user_data = <<-EOF
    #!/bin/bash
    sudo yum update -y
    sudo yum install httpd -y
    sudo systemctl enable httpd
    sudo systemctl start httpd
    cd /var/www/html
    curl http://169.254.169.254/latest/meta-data/instance-id -o index.html
    echo "<html><body><div>Hello,CH. This is Terraform. </div> </body></html>" >> /var/www/html/index.html
    EOF
  tags = {
    Terraform   = "true"
    Name        = var.Name
  }
}
