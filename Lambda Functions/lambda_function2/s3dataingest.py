import json
import boto3
import os
import logging
import psycopg2
from psycopg2.extras import execute_values

# Initialize logger for logging information and errors
logger = logging.getLogger()
logger.setLevel(logging.INFO)

def calculate_heat_index(temperature, humidity):
    # Function to calculate the heat index based on temperature and humidity
    logger.info(f"Calculating heat index for temp: {temperature}, humidity: {humidity}")
    # Simplified formula for heat index calculation
    heat_index = -42.379 + 2.04901523 * temperature + 10.14333127 * humidity - \
                 0.22475541 * temperature * humidity - 0.00683783 * temperature**2 - \
                 0.05481717 * humidity**2 + 0.00122874 * temperature**2 * humidity + \
                 0.00085282 * temperature * humidity**2 - 0.00000199 * temperature**2 * humidity**2
    return round(heat_index, 2)

def assess_comfort(temperature, humidity):
    # Function to assess comfort level based on temperature and humidity
    logger.info(f"Assessing comfort level for temp: {temperature}, humidity: {humidity}")
    # Simple logic to determine comfort level
    if temperature > 75 and humidity > 60:
        return "Uncomfortable"
    elif temperature < 40 and humidity < 30:
        return "Dry"
    else:
        return "Comfortable"

def fahrenheit_to_celsius(fahrenheit):
    # Function to convert Fahrenheit to Celsius
    logger.info(f"Converting fahrenheit to celsius: {fahrenheit}")
    return round((fahrenheit - 32) * 5.0 / 9.0, 2)

def process_weather_data(data):
    # Function to process raw weather data
    logger.info("Processing weather data")
    processed_data = []
    for record in data['weather_data']:
        temperature_f = record['temperature']  # Fahrenheit temperature
        temperature_c = fahrenheit_to_celsius(temperature_f)  # Convert to Celsius
        record['temperature_celsius'] = temperature_c
        record['heat_index'] = calculate_heat_index(temperature_f, record['humidity'])
        record['comfort_level'] = assess_comfort(temperature_f, record['humidity'])
        processed_data.append(record)
    return {'weather_data': processed_data}

def store_in_database(data):
    # Function to store processed data in the database
    try:
        db_config = {
            "dbname": os.environ['DB_NAME'],
            "user": os.environ['DB_USER'],
            "password": os.environ['DB_PASSWORD'],
            "host": os.environ['DB_HOST'],
            "port": os.environ['DB_PORT']
        }

        # SQL query for inserting data into the database
        insert_query = """
        INSERT INTO weather_data 
        (time, temperature, humidity, wind_speed, condition, temperature_celsius, heat_index, comfort_level) 
        VALUES %s
        """

        # Prepare data records for insertion
        records_list = [(d['time'], d['temperature'], d['humidity'], d['wind_speed'], d['condition'],
                         d['temperature_celsius'], d['heat_index'], d['comfort_level']) for d in data]

        # Connect to the database and execute the insertion
        with psycopg2.connect(**db_config) as conn:
            with conn.cursor() as cur:
                logger.info(f"Storing {len(records_list)} records in the database")
                execute_values(cur, insert_query, records_list)
                logger.info("Data stored successfully")

    except Exception as e:
        # Log any exceptions during database operations
        logger.error(f"Database connection failed due to {e}")

def lambda_handler(event, context):
    # Main Lambda handler function
    logger.info(f"Received event: {event}")
    try:
        # Initialize S3 client
        s3 = boto3.client('s3')
        bucket_name = event['Records'][0]['s3']['bucket']['name']
        file_key = event['Records'][0]['s3']['object']['key']

        # Retrieve and process the file from S3
        logger.info(f"Processing file {file_key} from bucket {bucket_name}")
        response = s3.get_object(Bucket=bucket_name, Key=file_key)
        content = response['Body'].read().decode('utf-8')
        weather_data = json.loads(content)

        processed_data = process_weather_data(weather_data)
        store_in_database(processed_data['weather_data'])

        return {'statusCode': 200, 'body': json.dumps("Data processed and stored successfully")}

    except Exception as e:
        # Log any exceptions during file processing
        logger.error(f"Error processing file {file_key} from bucket {bucket_name}: {e}")
        return {'statusCode': 500, 'body': json.dumps("Error processing the S3 file")}

