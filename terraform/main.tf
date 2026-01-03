provider "aws" {
  region = "us-east-1"
}

# Security group (firewall)
resource "aws_security_group" "web_sg" {
  name        = "devops-project-sg"
  description = "Allow HTTP and SSH"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 5000
    to_port     = 5000
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

# SSH keypair
resource "aws_key_pair" "deployer" {
  key_name   = "devops-project-key"
  public_key = var.public_key
}

# EC2 instance
resource "aws_instance" "app_server" {
  ami           = "ami-0c7217cdde317cfec" # Ubuntu 22.04 US-East-1
  instance_type = "t2.micro"
  key_name      = aws_key_pair.deployer.key_name
  security_groups = [aws_security_group.web_sg.name]

  user_data = <<-EOF
              #!/bin/bash
              sudo apt-get update
              sudo apt-get install -y docker.io
              sudo systemctl start docker
              sudo systemctl enable docker
              sudo usermod -aG docker ubuntu
              EOF

  tags = {
    Name = "DevOps-Project-Server"
  }
}

variable "public_key" {
  description = "Your public SSH key"
}

output "server_ip" {
  value = aws_instance.app_server.public_ip
}
