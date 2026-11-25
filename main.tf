# 1. Configuración del proveedor de AWS
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1" # Puedes cambiar la región si lo necesitas
}

# 2. Buscar la AMI más reciente de Ubuntu 22.04 LTS
data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"] # ID oficial de Canonical (Ubuntu)
}

# 3. Crear el Security Group (Cortafuegos)
resource "aws_security_group" "moodle_sg" {
  name = "moodle-sg-v2"
  description = "Permitir trafico SSH, HTTP y HTTPS"

  # SSH (Para que GitHub Actions pueda conectarse)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP (Para acceder a Moodle desde el navegador)
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  # HTTPS (Por si luego agregamos SSL)
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Permitir todo el tráfico de salida
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 4. Crear la instancia EC2
resource "aws_instance" "moodle_server" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro" # Capa gratuita
  key_name      = "moodle-key" # 
  
  vpc_security_group_ids = [aws_security_group.moodle_sg.id]

  # Script que se ejecuta al encender la máquina: Instala Docker y Docker Compose
  user_data = <<-EOF
              #!/bin/bash
              sudo apt-get update -y
              sudo apt-get install -y docker.io docker-compose git
              sudo systemctl start docker
              sudo systemctl enable docker
              sudo usermod -aG docker ubuntu
              EOF

  tags = {
    Name = "Moodle-Server-Actividad6"
  }
}