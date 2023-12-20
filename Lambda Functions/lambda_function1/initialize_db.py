# Lambda function to initialize db schema
import psycopg2 #for PostgreSQL database connectivity
import os

def lambda_handler(event, context):
    # Database connection settings
    db_config = {
        "dbname": os.environ['DB_NAME'],
        "user": os.environ['DB_USERNAME'],
        "password": os.environ['DB_PASSWORD'],
        "host": os.environ['DB_HOST'],
        "port": os.environ['DB_PORT']
    }

    # SQL script to initialize the database
    init_script = """
    CREATE TABLE IF NOT EXISTS weather_data (
        time VARCHAR(255),
        temperature INT,
        humidity INT,
        wind_speed INT,
        condition VARCHAR(255),
        temperature_celsius FLOAT,
        heat_index FLOAT,
        comfort_level VARCHAR(255)
    );
    """

    # Connect to the database and execute the SQL script
    with psycopg2.connect(**db_config) as conn:
        with conn.cursor() as cur:
            cur.execute(init_script)

    return {
        'statusCode': 200,
        'body': 'Database initialized successfully'
    }
