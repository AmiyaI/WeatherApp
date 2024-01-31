# WeatherApp

## Overview
WeatherApp is an AWS-based ETL (Extract, Transform, Load) pipeline designed for collecting, processing, storing, and managing weather data. Leveraging AWS services and Terraform for infrastructure deployment, it features AWS Lambda for data processing, Amazon RDS for database storage, and EC2 instances for CI/CD processes and secure access to the RDS database and other VPC resources.

## Project Structure
- **Lambda Functions**: Dockerized Python Lambda functions for processing weather data.
  - `initialize_db.py`: Creates a table in a PostgreSQL database for storing weather data. This script ensures that the necessary database structure is in place for data storage.
  - `s3dataingest.py`: Processes weather data from S3, calculates additional metrics like heat index and comfort level, and stores the processed data in the database. This function is crucial for transforming raw weather data into insightful, actionable information.
- **Mock Data**: Sample JSON files (`weather1.json` to `weather6.json`) for testing.
- **Terraform**: Infrastructure as Code (IaC) files for AWS resource management.
- **Tests**: Unit tests for the Lambda functions in Jenkins pipeline.
- **Jenkinsfile**: Configuration for the CI/CD pipeline.

## Key Components
- **AWS Lambda Functions**: Processes weather data and initializes the database schema.
- **EC2 Instances**:
  - **Jenkins Server**: Manages CI/CD pipeline for Dockerized Python Lambda functions.
  - **Bastion Host**: Provides secure access to RDS and other AWS resources.
- **Amazon RDS**: PostgreSQL database for storing processed weather data.
- **Amazon S3**: Buckets for weather data and Terraform state files.
- **DynamoDB**: Table for managing Terraform state locks.
- **IAM Roles and Policies**: Define permissions for secure operations of AWS services.
- **VPC Configuration**:
  - **Public Subnets**: Hosts Jenkins Server and Bastion Host.
  - **Private Subnets**: Hosts RDS database and Lambda functions.
  - Includes internet gateway, route tables, security groups, and a VPC endpoint for S3.
- **AWS Lambda Configuration**: Terraform setup for Lambda functions.
- **ECR Repository**: Stores Docker images for Lambda functions.
- **Jenkins Pipeline**: Automates testing, building Docker images, and deploying infrastructure.
- **Unit Testing**: Ensures functionality and reliability of Lambda functions.

## How It Works
- Weather data uploaded to S3 triggers the `s3dataingest` Lambda function for processing.
- The processed data is then stored in the RDS database for analysis.
- The Jenkins pipeline automates testing, building Docker images, and deploying infrastructure using Terraform.
- Secure access to the RDS database and other AWS resources is provided through the Bastion Host.
- A VPC endpoint enables private connections to S3 from within the VPC.
- DynamoDB ensures consistent Terraform state management across deployments.

## Security & Best Practices
- Security groups, IAM roles, Bastion Host, and VPC endpoint ensure secure access.
- Terraform backend with S3 and DynamoDB provides consistent state management.
- IAM roles and policies strictly control access to AWS services.
- Security groups and subnets provide network isolation.
- Sensitive data is managed using environment variables in Jenkins and a tfvars file in Terraform.
- The entire infrastructure is defined as code using Terraform for easy, consistent, and repeatable deployments.
- Regular commits to GitHub with documented changes for version control.
- Monitoring and alerts set up to promptly address any issues.

## Images
Below are images demonstrating various stages of the WeatherApp pipeline and database:

![Jenkins Pipeline Success](/Images/JenkinsPipelineSuccess.jpg)
<br>
**The Jenkins pipeline interface after a successful execution using BlueOcean, illustrating the completed CI/CD process.**

![Database after Initialization](/Images/DBafterInitialization.jpg)
<br>
**The PostgreSQL database view immediately after the schema initialization, ready to store weather data.**

![Database after Mock Data Being Processed](/Images/DBafterMockDataBeingProcessed.jpg)
<br>
**The database showing weather data records following the processing of mock data by the Lambda functions.**

## Conclusion
This project showcases comprehensive cloud engineering skills, including AWS service utilization, IaC, CI/CD processes, containerization, and adherence to security best practices. It demonstrates a real-world application of processing and analyzing weather data efficiently and effectively on the cloud. Thank you for checking out my project!
