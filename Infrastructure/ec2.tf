data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023*"]
  }

  filter {
    name   = "architecture"
    values = ["arm64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "jenkins_server" {
  ami                    = data.aws_ami.amazon_linux_2023.id #Amazon Linux 2023 AMI
  instance_type          = "t2.micro"
  key_name               = "mumbai-key"
  vpc_security_group_ids = [aws_security_group.allow_jenkins_server_traffic.id]
  tags = {
    Name  = "jenkins-server-deployment-using-terraform"
    Owner = "learnwithaniket.com"
  }

  user_data = <<-EOF
    #!/bin/bash
    sudo yum update –y
    sudo wget -O /etc/yum.repos.d/jenkins.repo \
    https://pkg.jenkins.io/redhat-stable/jenkins.repo
    sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
    sudo yum upgrade -y
    sudo amazon-linux-extras install java-openjdk11 -y
    sudo yum install jenkins -y
    sudo systemctl enable jenkins
    sudo systemctl start jenkins
    sudo systemctl status jenkins
    EOF
}

resource "aws_security_group" "allow_jenkins_server_traffic" {
  name        = "jenkins_server"
  description = "Allow SSH and HTTP traffic to Jenkins server"
  vpc_id      = "vpc-bf231bd7"
}

resource "aws_security_group_rule" "allow_ssh" {
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  security_group_id = aws_security_group.allow_jenkins_server_traffic.id
  type              = "ingress"
  cidr_blocks       = ["${var.your_ip}/32"]
}

resource "aws_security_group_rule" "allow_jenkins_server" {
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  security_group_id = aws_security_group.allow_jenkins_server_traffic.id
  type              = "ingress"
  cidr_blocks       = ["${var.your_ip}/32"]
}

resource "aws_security_group_rule" "allow_egress" {
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.allow_jenkins_server_traffic.id
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
}
