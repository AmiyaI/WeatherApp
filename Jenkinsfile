pipeline {
    agent any

    environment {
        // Define your environment variables here
        AWS_DEFAULT_REGION = 'us-east-1'
        ECR_REPO_URI = '004678516606.dkr.ecr.us-east-1.amazonaws.com/my-lambda-repo'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm // Checks out the source code
            }
        }

        stage('Unit Test') {
            steps {
                sh 'echo "Running unit tests"'
                // Run unit tests command here
                sh 'python -m unittest discover -s Tests'
            }
        }

        stage('Build and Push Docker Images') {
            steps {
                script {
                    withCredentials([usernameVariable: 'AWS_ACCESS_KEY_ID', passwordVariable: 'AWS_SECRET_ACCESS_KEY', credentialsId: 'AWS_CREDENTIALS_ID']) {
                        // Authenticate with ECR
                        sh "aws ecr get-login-password --region ${AWS_DEFAULT_REGION} | docker login --username AWS --password-stdin ${ECR_REPO_URI}"
                        
                        // Building and pushing the first lambda function - initialize_db
                        sh """
                        docker buildx build --platform linux/amd64 -t ${ECR_REPO_URI}:initialize_db-latest -f "Lambda Functions/lambda_function1/Dockerfile" "Lambda Functions/lambda_function1"
                        docker tag ${ECR_REPO_URI}:initialize_db-latest ${ECR_REPO_URI}:initialize_db-${GIT_COMMIT}
                        docker push ${ECR_REPO_URI}:initialize_db-${GIT_COMMIT}
                        """

                        // Building and pushing the second lambda function - s3dataingest
                        sh """
                        docker buildx build --platform linux/amd64 -t ${ECR_REPO_URI}:s3dataingest-latest -f "Lambda Functions/lambda_function2/Dockerfile" "Lambda Functions/lambda_function2"
                        docker tag ${ECR_REPO_URI}:s3dataingest-latest ${ECR_REPO_URI}:s3dataingest-${GIT_COMMIT}
                        docker push ${ECR_REPO_URI}:s3dataingest-${GIT_COMMIT}
                        """
                    }
                }
            }
        }

        stage('Deploy') {
            steps {
                sh 'echo "Deploying using Terraform"'
                script {
                    // Initialize Terraform and apply
                    sh """
                    cd terraform
                    terraform init
                    terraform apply -auto-approve \
                        -var 's3dataingest_image_uri=${ECR_REPO_URI}:s3dataingest-${GIT_COMMIT}' \
                        -var 'initialize_db_image_uri=${ECR_REPO_URI}:initialize_db-${GIT_COMMIT}'
                    """
                }
            }
        }
    }

    post {
        always {
            echo 'This will always run'
        }
        success {
            echo 'This will run only if successful'
        }
        failure {
            echo 'This will run only if failed'
        }
    }
}
