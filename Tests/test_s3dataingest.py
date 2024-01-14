# test_s3dataingest.py
import sys
import unittest
from unittest.mock import patch
sys.path.append('../Lambda Functions/lambda_function2')
from s3dataingest import lambda_handler

class S3DataIngestTestCase(unittest.TestCase):

    @patch('boto3.client')
    def test_lambda_handler_with_mock_data(self, mock_boto3_client):
        # Mocking AWS services
        mock_s3 = mock_boto3_client.return_value
        mock_s3.get_object.return_value = {
            'Body': {
                'read': lambda: '''
                {
                    "weather_data": [
                        {
                            "time": "2023-12-08T08:00:00Z",
                            "temperature": 72,
                            "humidity": 50,
                            "wind_speed": 10,
                            "condition": "Sunny"
                        },
                        {
                            "time": "2023-12-08T09:00:00Z",
                            "temperature": 74,
                            "humidity": 45,
                            "wind_speed": 12,
                            "condition": "Partly Cloudy"
                        }
                    ]
                }'''
            }
        }

        # Simulate Lambda event and context (simplified)
        event = {
            # Simulate the necessary event structure here
        }
        context = {}

        # Act: Call the lambda_handler function with the mock data
        response = lambda_handler(event, context)

        # Assert: Make assertions about the response or any side effects
        # Assertions will depend on what lambda_handler returns and its side effects
        self.assertEqual(response['statusCode'], 200)
        self.assertIn("Data processed and stored successfully", response['body'])
        # Add more assertions as necessary based on how your function should process the mock data

if __name__ == '__main__':
    unittest.main()
