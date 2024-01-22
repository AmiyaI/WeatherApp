/*
# Fetch the latest Amazon Linux AMI 
data "aws_ssm_parameter" "amazon_linux_2023" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-minimal-kernel-default-x86_64"
}
ami command: ami = data.aws_ssm_parameter.amazon_linux_2023.value
*/

# Data block to dynamically select the latest Amazon Linux AMI
data "aws_ami" "amazon_linux_2023" {
  most_recent = true

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-kernel-6.1-x86_64"] # Pattern to match the naming convention
  }

  owners = ["amazon"]
}


# Jenkins EC2 Instance Configuration
resource "aws_instance" "jenkins" {
  ami             = data.aws_ami.amazon_linux_2023.id
  instance_type   = "t3.small"
  key_name        = "JasonBourne"
  subnet_id       = aws_subnet.public-1.id
  #security_groups = [aws_security_group.jenkins_sg.id]
  vpc_security_group_ids = [aws_security_group.jenkins_sg.id]
  tags = {
    Name = "JenkinsServer"
  }

  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name

  # User data script to setup Jenkins
  user_data = <<-EOF
    #!/bin/bash
    set -e

    # Update system packages
    yum update -y

    # Install Docker
    yum install docker -y
    systemctl start docker
    systemctl enable docker
    usermod -aG docker ec2-user

    # Create mount directory for Jenkins if it doesn't exist
    mkdir -p /mnt/jenkins_home

    # Format and mount EBS volume if necessary
    FS_TYPE=$(file -s /dev/nvme1n1 | cut -d , -f 1 | awk '{ print $2 }')
    if [ "$FS_TYPE" == "data" ]; then
        mkfs -t ext4 /dev/nvme1n1
    fi
    mount /dev/nvme1n1 /mnt/jenkins_home
    echo '/dev/nvme1n1 /mnt/jenkins_home ext4 defaults,nofail 0 2' >> /etc/fstab

    # Set permissions for Jenkins
    chown -R 1000:1000 /mnt/jenkins_home
    chmod -R 755 /mnt/jenkins_home

    # Run Jenkins Docker container with mounted volume and Docker socket
    docker pull jenkins/jenkins:lts
    docker run -d --restart unless-stopped --name jenkins -p 8080:8080 -p 50000:50000 \
        -v /mnt/jenkins_home:/var/jenkins_home \
        -v /var/run/docker.sock:/var/run/docker.sock \
        -u root \
        jenkins/jenkins:lts

    # Wait for Jenkins to start
    until docker exec jenkins ls /var/jenkins_home; do sleep 5; done

    # Install Docker CLI inside Jenkins container
    docker exec jenkins apt-get update
    docker exec jenkins apt-get install -y docker.io

    # Install common utilities and AWS CLI v2
    yum install -y jq git unzip
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip awscliv2.zip
    ./aws/install
    rm -f awscliv2.zip awscliv2.zip
  EOF
}

# Elastic IP for Jenkins Instance
resource "aws_eip" "jenkins_eip" {
  instance = aws_instance.jenkins.id

  lifecycle {
    create_before_destroy = true
  }
}

#EBS Volume for Jenkins EC2 Instance
resource "aws_ebs_volume" "jenkins_data" {
  availability_zone = aws_instance.jenkins.availability_zone
  size              = 10
  type              = "gp3" # General purpose SSD
  #snapshot_id       = ""
  lifecycle {
    prevent_destroy = true
  }

  tags = {
    Name = "JenkinsData"
  }
}
#EBS Volume Attachment
resource "aws_volume_attachment" "jenkins_ebs_attach" {
  device_name  = "/dev/sdh" # or xvdf or another appropriate device name, still shows up as xvdh instead of /dev/sdh
  volume_id    = aws_ebs_volume.jenkins_data.id
  instance_id  = aws_instance.jenkins.id
  force_detach = true
}

# Jenkins Security Group Configuration
resource "aws_security_group" "jenkins_sg" {
  name        = "jenkins-sg"
  description = "Security group for Jenkins server"
  vpc_id      = aws_vpc.main.id

  # Ingress rules for Jenkins
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = [var.my_ip] # HTTP access to Jenkins
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip] # SSH access
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = [var.panera_ip]
  }

  ingress {
    from_port   = 22 # SSH Port
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.panera_ip]

  }

  # Egress rule: Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Bastion Host Configuration
resource "aws_instance" "bastion_host" {
  ami           = data.aws_ami.amazon_linux_2023.id
  instance_type = var.instance_type
  key_name      = "JasonBourne"
  subnet_id     = aws_subnet.public-1.id
  #security_groups = [aws_security_group.bastion_sg.id] #- forces recreation every tf apply
  vpc_security_group_ids = [aws_security_group.bastion_sg.id]

  tags = {
    Name = "BastionHost"
  }

  iam_instance_profile = aws_iam_instance_profile.bastion_profile.name

  # User data script to setup Bastion Host
  user_data = <<-EOF
      #!/bin/bash
      # Update system packages
      yum update -y

      # Install Docker
      yum install docker -y
      systemctl start docker
      systemctl enable docker
      usermod -aG docker ec2-user

      # Pull PostgreSQL Docker image
      docker pull postgres:15

      # Install common utilities
      yum install -y jq git unzip

      # Install AWS CLI v2
      curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
      unzip awscliv2.zip
      ./aws/install

      # Clean up installation files
      rm -f awscliv2.zip
  EOF
}

# Elastic IP for Bastion Host
resource "aws_eip" "bastion_eip" {
  instance = aws_instance.bastion_host.id

  lifecycle {
    create_before_destroy = true
  }
}

# Bastion Security Group Configuration
resource "aws_security_group" "bastion_sg" {
  name        = "bastion_sg"
  description = "Security group for Bastion Host"
  vpc_id      = aws_vpc.main.id

  # Ingress rules for Bastion Host
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip] # SSH access
  }

  ingress {
    from_port   = 22 # SSH Port
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.panera_ip] # Panera Bread IP
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # Allow all outbound traffic
    cidr_blocks = ["0.0.0.0/0"]
  }

}
