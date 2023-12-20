# Use the AWS Lambda Python runtime as a base
FROM public.ecr.aws/lambda/python:3.11

# Update system packages - optional, but recommended for security patches
RUN yum update -y && yum clean all

# Copy the requirements.txt file to the container
COPY requirements.txt ./

# Install the Python requirements from requirements.txt
RUN pip install -r requirements.txt --target "${LAMBDA_TASK_ROOT}"

# Copy the lambda function code to the container
COPY s3dataingest.py ${LAMBDA_TASK_ROOT}

# Set the CMD to your handler (this will be overridden by the specific Lambda configuration)
CMD ["s3dataingest.lambda_handler"]
