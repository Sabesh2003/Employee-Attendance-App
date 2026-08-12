terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  required_version = ">= 1.5.0"
}

provider "aws" {
  region = var.aws_region
}

# -------------------------
# Default VPC
# -------------------------

data "aws_vpc" "default" {
  default = true
}

# -------------------------
# Default Subnets
# -------------------------

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# -------------------------
# Latest Amazon Linux 2023
# -------------------------

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# -------------------------
# Security Group
# -------------------------

resource "aws_security_group" "employee_attendance" {
  name        = "${var.project_name}-sg"
  description = "Security group for Employee Attendance application"
  vpc_id      = data.aws_vpc.default.id

  # SSH
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Flask application
  ingress {
    description = "Employee Attendance App"
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "${var.project_name}-sg"
    Project = var.project_name
  }
}

# -------------------------
# EC2 Instance
# -------------------------

resource "aws_instance" "employee_attendance" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type

  subnet_id = data.aws_subnets.default.ids[0]

  vpc_security_group_ids = [
    aws_security_group.employee_attendance.id
  ]

  user_data = <<-EOF
              #!/bin/bash
              dnf update -y
              dnf install -y docker
              systemctl enable docker
              systemctl start docker

              usermod -aG docker ec2-user

              docker pull sabesh2003/attendance-app:latest

              docker run -d \
                --name employee-attendance \
                -p 5000:5000 \
                --restart unless-stopped \
                sabesh2003/attendance-app:latest
              EOF

  tags = {
    Name    = "${var.project_name}-server"
    Project = var.project_name
  }
}