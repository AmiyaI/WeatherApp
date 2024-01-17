pipeline {
    agent any // Use any available agent

    environment {
        // Define environment variables for the pipeline
        AWS_DEFAULT_REGION = 'us-east-1'
        ECR_REPO_URI = '004678516606.dkr.ecr.us-east-1.amazonaws.com/my-lambda-repo'
    }

    stages {
        stage('Checkout') {
            steps {
                // Checkout the source code from the repository
                checkout scm
            }
        }

        stage('Unit Test') {
            agent {
                // Use Docker-in-Docker for running unit tests
                docker {
                    image 'docker:dind' // Docker-in-Docker image
                    args '--privileged -v /var/run/docker.sock:/var/run/docker.sock' // Mount the host's Docker socket
                }
            }
            steps {
                echo "Running unit tests"
                // Execute unit tests within the Python Docker container
                sh '''
                    docker pull python:3.11
                    docker run --rm -v $WORKSPACE:/workspace -w /workspace python:3.11 python -m unittest discover -s Tests
                '''
            }
        }

        stage('Build and Push Docker Images') {
            steps {
                script {
                    // Use stored AWS credentials for ECR authentication
                    withCredentials([usernameVariable: 'AWS_ACCESS_KEY_ID', passwordVariable: 'AWS_SECRET_ACCESS_KEY', credentialsId: 'AWS_CREDENTIALS_ID']) {
                        // Authenticate with ECR
                        sh "aws ecr get-login-password --region ${AWS_DEFAULT_REGION} | docker login --username AWS --password-stdin ${ECR_REPO_URI}"
                        
                        // Build and push the Docker images
                        sh '''
                            docker buildx build --platform linux/amd64 -t ${ECR_REPO_URI}:initialize_db-latest -f "Lambda Functions/lambda_function1/Dockerfile" "Lambda Functions/lambda_function1"
                            docker tag ${ECR_REPO_URI}:initialize_db-latest ${ECR_REPO_URI}:initialize_db-${GIT_COMMIT}
                            docker push ${ECR_REPO_URI}:initialize_db-${GIT_COMMIT}
                            
                            docker buildx build --platform linux/amd64 -t ${ECR_REPO_URI}:s3dataingest-latest -f "Lambda Functions/lambda_function2/Dockerfile" "Lambda Functions/lambda_function2"
                            docker tag ${ECR_REPO_URI}:s3dataingest-latest ${ECR_REPO_URI}:s3dataingest-${GIT_COMMIT}
                            docker push ${ECR_REPO_URI}:s3dataingest-${GIT_COMMIT}
                        '''
                    }
                }
            }
        }

        stage('Deploy') {
            steps {
                echo "Deploying using Terraform"
                script {
                    // Change directory to Terraform configuration and execute deployment
                    sh '''
                        cd terraform
                        terraform init
                        terraform apply -auto-approve \
                            -var "s3dataingest_image_uri=${ECR_REPO_URI}:s3dataingest-${GIT_COMMIT}" \
                            -var "initialize_db_image_uri=${ECR_REPO_URI}:initialize_db-${GIT_COMMIT}"
                    '''
                }
            }
        }
    }

    post {
        // Define post-build actions
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
