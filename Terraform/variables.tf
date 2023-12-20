# Terraform Variable Definitions

#EC2 Variables
variable "instance_type" {
  description = "EC2 instance type for Jenkins server and Bastion Host"
  type        = string
  default     = "t2.micro"
}

#RDS Variables
variable "db_username" {
  description = "Username for the database."
  type        = string
  default     = ""
}

variable "db_password" {
  description = "Password for the database."
  type        = string
  default     = ""
  sensitive   = true # Marks the variable as sensitive, hiding it in logs
}

variable "db_name" {
  description = "The name of the database."
  type        = string
  default     = "WeatherDB"
}

variable "db_port" {
  description = "The port on which the database is listening."
  type        = string
  default     = "5432"
}


# IP Addresses
variable "my_ip" {
  description = "My public IP"
  type        = string
  default     = ""
}

variable "panera_ip" {
  description = "Panera Bread IP" #For when working at Panera
  type        = string
  default     = ""
}
