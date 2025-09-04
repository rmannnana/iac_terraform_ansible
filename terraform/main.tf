# Configuration du provider AWS
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.0"
}

# Configuration des credentials AWS
provider "aws" {
  region = var.aws_region
}

# Variables
variable "aws_region" {
  description = "Région AWS à utiliser"
  type        = string
  default     = "eu-west-1"
}

variable "instance_type" {
  description = "Type d'instance EC2"
  type        = string
  default     = "t3.micro"
}

# Données pour récupérer l'AMI Ubuntu la plus récente
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Création d'un groupe de sécurité
resource "aws_security_group" "web_sg" {
  name        = "web-security-group"
  description = "Groupe de sécurité pour serveur web"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Création de l'instance EC2
resource "aws_instance" "web_server" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  key_name               = "my-key-pair" # Remplacez par votre paire de clés

  tags = {
    Name        = "WebServer"
    Environment = "Development"
  }
}

# Outputs
output "instance_ip" {
  description = "Adresse IP publique de l'instance"
  value       = aws_instance.web_server.public_ip
}

output "instance_dns" {
  description = "DNS public de l'instance"
  value       = aws_instance.web_server.public_dns
} 