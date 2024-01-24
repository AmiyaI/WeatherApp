pipeline {
    agent any // Use any available agent

    environment {
        // Define environment variables for the pipeline
        AWS_DEFAULT_REGION = 'us-east-1'
        ECR_REPO_URI = '004678516606.dkr.ecr.us-east-1.amazonaws.com/my-lambda-repo'
        TF_LOG = 'DEBUG' // Set Terraform logging to DEBUG level
    }

    stages {
        stage('Clean Workspace') {
            steps {
                cleanWs()
            }
        }

        stage('Checkout') {
            steps {
                // Checkout the source code from the repository
                checkout scm
            }
        }

        stage('Unit Test') {
            steps {
                echo "Running unit tests"
                // Pull the Python Docker image and run unit tests
                sh '''
                    docker pull python:3.11
                    docker run --rm -v /var/jenkins_home/workspace/WeatherApp:/workspace -w /workspace python:3.11 python -m unittest discover
                '''
            }
        }

        stage('Build and Push Docker Images') {
            steps {
                script {
                    // Pull the AWS CLI Docker image and run it to execute AWS commands
                    sh 'docker pull amazon/aws-cli'
                    sh 'docker run --rm -v /var/run/docker.sock:/var/run/docker.sock amazon/aws-cli ecr get-login-password --region ${AWS_DEFAULT_REGION} | docker login --username AWS --password-stdin ${ECR_REPO_URI}'

                    // Use stored AWS credentials for ECR authentication
                    withCredentials([usernamePassword(credentialsId: 'AWS-CREDENTIALS-ID', usernameVariable: 'AWS_ACCESS_KEY_ID', passwordVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                        // Build and push the Docker images
                        sh '''
                            docker build -t ${ECR_REPO_URI}:initialize_db-latest -f "Lambda Functions/lambda_function1/Dockerfile" "Lambda Functions/lambda_function1"
                            docker tag ${ECR_REPO_URI}:initialize_db-latest ${ECR_REPO_URI}:initialize_db-${GIT_COMMIT}
                            docker push ${ECR_REPO_URI}:initialize_db-${GIT_COMMIT}

                            docker build -t ${ECR_REPO_URI}:s3dataingest-latest -f "Lambda Functions/lambda_function2/Dockerfile" "Lambda Functions/lambda_function2"
                            docker tag ${ECR_REPO_URI}:s3dataingest-latest ${ECR_REPO_URI}:s3dataingest-${GIT_COMMIT}
                            docker push ${ECR_REPO_URI}:s3dataingest-${GIT_COMMIT}
                        '''
                    }
                }
            }
        }

        stage('Setup Terraform') {
            steps {
                script {
                    // Check if Terraform is installed
                    if (sh(script: 'which terraform', returnStatus: true) != 0) {
                        echo 'Installing Terraform...'
                        sh '''
                            curl -O https://releases.hashicorp.com/terraform/1.6.5/terraform_1.6.5_linux_amd64.zip
                            unzip terraform_1.6.5_linux_amd64.zip
                            mv terraform /usr/local/bin/
                        '''
                    } else {
                        echo 'Terraform is already installed.'
                    }
                }
            }
        }

        stage('Deploy') {
            steps {
                echo "Deploying using Terraform"
                script {
                    // Inject IP variables from Jenkins credentials
                    withCredentials([
                        string(credentialsId: 'MY_IP', variable: 'MY_IP'),
                        string(credentialsId: 'PANERA_IP', variable: 'PANERA_IP'),
                        string(credentialsId: 'DB_USERNAME', variable: 'DB_USERNAME'),
                        string(credentialsId: 'DB_PASSWORD', variable: 'DB_PASSWORD')
                    ]) {
                        // Change directory to Terraform configuration and execute deployment
                        sh """
                            cd Terraform
                            terraform init
                            terraform apply auto-approve \
                                -var "db_username=${DB_USERNAME}" \
                                -var "db_password=${DB_PASSWORD}" \
                                -var "my_ip=${MY_IP}" \
                                -var "panera_ip=${PANERA_IP}" \
                                -var "s3dataingest_image_uri=${ECR_REPO_URI}:s3dataingest-${GIT_COMMIT}" \
                                -var "initialize_db_image_uri=${ECR_REPO_URI}:initialize_db-${GIT_COMMIT}" | tee terraform_output.log
                        """
                    }
                    archiveArtifacts artifacts: 'Terraform/terraform_output.log', onlyIfSuccessful: false
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
