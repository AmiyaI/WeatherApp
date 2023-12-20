# RDS instance configuration
resource "aws_db_instance" "default" {
  allocated_storage    = 20 # Minimum storage for free tier
  storage_type         = "gp2"
  db_name              = var.db_name
  engine               = "postgres"
  engine_version       = "15.4"        # Use preferred PostgreSQL version
  instance_class       = "db.t3.micro" # Instance type eligible for free tier
  username             = var.db_username
  password             = var.db_password
  parameter_group_name = "default.postgres15"
  skip_final_snapshot  = true
  db_subnet_group_name = aws_db_subnet_group.default.name

  # Uncomment to make the database publicly accessible
  # publicly_accessible = true

  # Security group for controlling access to the RDS instance
  vpc_security_group_ids = [aws_security_group.db_sg.id]

  tags = {
    Name = var.db_name
  }
}

# Database Subnet Group
resource "aws_db_subnet_group" "default" {
  name       = "my-db-subnet-group"
  subnet_ids = [aws_subnet.private-1.id, aws_subnet.private-2.id]

  tags = {
    Name = "My DB Subnet Group"
  }
}

# Security Group for the RDS instance
resource "aws_security_group" "db_sg" {
  name        = "my_db_sg"
  description = "Allow inbound traffic"
  vpc_id      = aws_vpc.main.id

  # Ingress rules - PostgreSQL default port
  ingress {
    from_port   = var.db_port
    to_port     = var.db_port
    protocol    = "tcp"
    cidr_blocks = ["10.0.1.0/24"] # Acess from Cloud9 + Bastion Host - Public Subnet 1 IP
  }

  # Additional ingress rule for Lambda function access
  ingress {
    from_port       = var.db_port
    to_port         = var.db_port
    protocol        = "tcp"
    security_groups = [aws_security_group.lambda_sg.id]
  }

  # Egress rule - allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "my_db_sg"
  }
}

