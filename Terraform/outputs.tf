# Terraform Output Values Configuration

# Output for Lambda Function Name
output "lambda_function_name" {
  value = aws_lambda_function.weather_processor.function_name
}

# Output for RDS Instance Endpoint 
output "rds_endpoint" {
  value = aws_db_instance.default.endpoint
}

# Output for RDS Instance Identifier
output "rds_instance_identifier" {
  description = "The identifier of the RDS instance"
  value       = aws_db_instance.default.id
}

# Output for Bastion Host Elastic IP
output "bastion_host_elastic_ip" {
  description = "Elastic IP of the Bastion Host"
  value       = aws_eip.bastion_eip.public_ip
}

# Output for Jenkins Server Elastic IP
output "jenkins_server_elastic_ip" {
  description = "Elastic IP of the Jenkins Server"
  value       = aws_eip.jenkins_eip.public_ip
}

# Output for Bastion Host Instance ID
output "bastion_host_instance_id" {
  description = "Instance ID of the Bastion Host"
  value       = aws_instance.bastion_host.id
}

# Output for Jenkins Server Instance ID
output "jenkins_server_instance_id" {
  description = "Instance ID of the Jenkins Server"
  value       = aws_instance.jenkins.id
}
