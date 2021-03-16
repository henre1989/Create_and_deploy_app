terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "3.31.0"
    }
  }
}

provider "aws" {
  region = "us-east-2"
}

resource "aws_instance" "build" {
  ami           = "ami-08962a4068733a2b6"
  instance_type = "t2.micro"
  key_name = "tf-key"
  associate_public_ip_address = true

tags = {
    Name = "build_server"
  }
}

resource "aws_security_group" "build" {
  name        = "Build Server Security Group"
  description = "My Build Server Security Group"

  ingress {
    description = "ssh"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    }
  }

output "instance_ips" {
  value = aws_instance.build.public_ip
}

resource "aws_instance" "Run_app" {
  ami           = "ami-08962a4068733a2b6"
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.run_app.id]
  key_name = "tf-key"
tags = {
    Name = "run_app_server"
  }
}

resource "aws_security_group" "run_app" {
  name        = "Running Server Security Group"
  description = "Running Server Security Group"


  ingress {
    description = "tomcat ports"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description = "ssh"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Run_app"
  }

}