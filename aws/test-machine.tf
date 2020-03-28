variable "vpc_somos"{
  default = "vpc-9c427df8"
}

provider "aws" {
  version = "~> 2.0"
  region  = "us-east-1"
}

resource "aws_security_group" "sg-test-machine" {
  name        = "Test Machine"
  description = "Test Machine"
  vpc_id      = "${var.vpc_somos}"

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    cidr_blocks     = ["10.63.116.0/23","10.63.114.0/23","10.63.14.0/24","187.20.141.156/32"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "monitoring-test" {
  ami                         = "ami-04b9e92b5572fa0d1"
  instance_type               = "t3.small"
  key_name                    = "devops-adm-virginia"
  subnet_id                   = "subnet-6912ae43"
  associate_public_ip_address = true
  security_groups             = ["${aws_security_group.sg-test-machine.id}"]

  user_data     = <<SCRIPT
#!/bin/bash
ln -sf /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime
echo "INSTALL TERRAFORM"
apt-get update -q && apt-get -y install unzip
curl -L "https://releases.hashicorp.com/terraform/0.12.17/terraform_0.12.17_linux_amd64.zip" -o /tmp/terraform_0.12.17_linux_amd64.zip
unzip /tmp/terraform_0.12.17_linux_amd64.zip -d /usr/local/bin
echo "INSTALL DOCKER"
curl -fsSL https://get.docker.com/ | bash
usermod -aG docker ubuntu
echo "INSTALL DOCKER-COMPOSE"
curl -L "https://github.com/docker/compose/releases/download/1.23.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
echo "UPDATE O.S."
apt-get update && DEBIAN_FRONTEND=noninteractive apt-get upgrade -y -o Dpkg::Options::="--force-confdef"
SCRIPT

tags = {
  Name        = "Test Machine"
  Owner       = "SETS"
  Environment = "Test"
}

}
