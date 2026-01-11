
variable "aws_region" {
  description = "AWS region to deploy the EC2 instance into"
  type        = string
  default     = "eu-west-2"
}

variable "aws_profile" {
  description = "AWS CLI profile used by Terraform"
  type        = string
  default     = "terraform-student"
}

variable "instance_type" {
  description = "EC2 instance size"
  type        = string
  default     = "t3.micro"
}

# Provider

provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}

# Security Group for SSH access

resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Security group allowing SSH inbound and all outbound"

# SSH access
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# EC2 Instance

resource "aws_instance" "dev_instance" {
  ami                    = "ami-01f43da22ee0fbf95"  
  instance_type          = var.instance_type
  key_name               = "devops_project_key"
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]  # Attach SG

  # Startup script – simple update and confirmation, the "welcome.txt" file confirms our user_data script worked.
  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              echo "Instance provisioned via Terraform" > /home/ec2-user/welcome.txt
              EOF

  tags = {
    Name        = "TerraformDemoInstance"
    Environment = "Dev"
  }
}


# Outputs

output "instance_public_ip" {
  description = "The public IP address of the EC2 instance"
  value       = aws_instance.dev_instance.public_ip
}
