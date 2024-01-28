# test_s3dataingest.py
import sys
import unittest
from unittest.mock import patch, MagicMock
import json

# Explicitly specify the full path to the lambda function directory
sys.path.append('/var/jenkins_home/workspace/WeatherApp/Lambda Functions/lambda_function2')

from s3dataingest import lambda_handler

class S3DataIngestTestCase(unittest.TestCase):
    @patch('boto3.client')
    def test_lambda_handler_with_mock_data(self, mock_boto3_client):
        # Mocking AWS services
        mock_s3 = mock_boto3_client.return_value
        mock_body = MagicMock()
        mock_body.read.return_value = json.dumps({
            "weather_data": [
                {
                    "time": "2023-12-08T08:00:00Z",
                    "temperature": 100,
                    "humidity": 50,
                    "wind_speed": 10,
                    "condition": "Unit Test"
                },
                {
                    "time": "2023-12-08T09:00:00Z",
                    "temperature": 30,
                    "humidity": 45,
                    "wind_speed": 12,
                    "condition": "Unit Test 1"
                }
            ]
        }).encode('utf-8')
        mock_s3.get_object.return_value = {'Body': mock_body}

        # Provide a mock event with the necessary structure
        mock_event = {
            'Records': [
                {
                    's3': {
                        'bucket': {
                            'name': 'test-bucket'
                        },
                        'object': {
                            'key': 'test-key.json'
                        }
                    }
                }
            ]
        }
        mock_context = {}

        # Act: Call the lambda_handler function with the mock data
        response = lambda_handler(mock_event, mock_context)

        # Assert: Make assertions about the response or any side effects
        self.assertEqual(response['statusCode'], 200)
        self.assertIn("Data processed and stored successfully", response['body'])

if __name__ == '__main__':
    unittest.main()
