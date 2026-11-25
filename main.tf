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

# 3. Buscar el Security Group existente
data "aws_security_group" "moodle_sg" {
  name = "moodle-sg" # Usamos el nombre original que ya existe en AWS
}

# 4. Crear la instancia EC2
resource "aws_instance" "moodle_server" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro" # Capa gratuita
  key_name      = "moodle-key" # 
  
  vpc_security_group_ids = [data.aws_security_group.moodle_sg.id]

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