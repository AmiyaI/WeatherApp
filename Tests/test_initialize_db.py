# test_initialize_db.py
import os
import sys
import unittest
from unittest.mock import patch, MagicMock

# Explicitly specify the full path to the lambda function directory
sys.path.append('/var/jenkins_home/workspace/WeatherApp/Lambda Functions/lambda_function1')

from initialize_db import lambda_handler

class InitializeDBTestCase(unittest.TestCase):
    @patch('initialize_db.psycopg2')
    @patch.dict(os.environ, {
        'DB_NAME': 'test_db',
        'DB_USERNAME': 'test_user',
        'DB_PASSWORD': 'test_password',
        'DB_HOST': 'test_host',
        'DB_PORT': '5432'
    })
    def test_lambda_handler(self, mock_psycopg2):
        # Arrange: Set up any data or state needed for the test
        mock_conn = MagicMock()
        mock_cur = MagicMock()

        mock_psycopg2.connect.return_value = mock_conn
        mock_conn.cursor.return_value = mock_cur

        # Act: Call the lambda_handler function
        response = lambda_handler(event={}, context={})

        # Assert: Make assertions about the response or any side effects
        self.assertEqual(response['statusCode'], 200)
        self.assertEqual(response['body'], 'Database initialized successfully')

        # Ensure the cursor executed some SQL command
        mock_cur.execute.assert_called_with("""
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
        """)

if __name__ == '__main__':
    unittest.main()
