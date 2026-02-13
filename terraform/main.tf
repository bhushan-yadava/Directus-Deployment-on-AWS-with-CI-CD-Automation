provider "aws" {
  region = var.aws_region
}

# ----------------------------
# Random suffix (avoid duplicates)
# ----------------------------
resource "random_id" "suffix" {
  byte_length = 4
}

# ----------------------------
# Get latest Ubuntu 22.04 AMI
# ----------------------------
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

# ----------------------------
# Generate SSH Key
# ----------------------------
resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  key_name   = "directus-key-${random_id.suffix.hex}"
  public_key = tls_private_key.ssh_key.public_key_openssh
}

# ----------------------------
# Security Group
# ----------------------------
resource "aws_security_group" "directus_sg" {
  name        = "directus-sg-${random_id.suffix.hex}"
  description = "Allow SSH, HTTP and Directus access"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Directus"
    from_port   = 8055
    to_port     = 8055
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

# ----------------------------
# EC2 Instance
# ----------------------------
resource "aws_instance" "directus_server" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t3.micro"
  associate_public_ip_address = true

  key_name               = aws_key_pair.generated_key.key_name
  vpc_security_group_ids = [aws_security_group.directus_sg.id]

  tags = {
    Name = "directus-server"
  }

  user_data = <<-EOF
#!/bin/bash
apt update -y
apt install -y docker.io curl

systemctl enable docker
systemctl start docker

# Install Docker Compose v2
mkdir -p /usr/libexec/docker/cli-plugins
curl -SL https://github.com/docker/compose/releases/latest/download/docker-compose-linux-x86_64 \
  -o /usr/libexec/docker/cli-plugins/docker-compose

chmod +x /usr/libexec/docker/cli-plugins/docker-compose

usermod -aG docker ubuntu
EOF
}
