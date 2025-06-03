from dataclasses import dataclass

import pytest
import tempfile

MOCK_INTERACTION_ID = "88888888-4444-4444-4444-121212121212"
REGION_NAME = "us-east-1"
MOCK_BUCKET = "test-s3-bucket"

@pytest.fixture
def mock_invalid_event_empty_query_string():
    api_gateway_event = {
        "httpMethod": "GET",
        "queryStringParameters": {},
        "headers": {},
    }

    return api_gateway_event

@pytest.fixture
def mock_invalid_event_without_date():
    api_gateway_event = {
        "httpMethod": "GET",
        "queryStringParameters": {"not a date string": "hello"},
        "headers": {},
    }

    return api_gateway_event

@pytest.fixture
def mock_invalid_event_invalid_date_format():
    api_gateway_event = {
        "httpMethod": "GET",
        "queryStringParameters": {"date": "hello"},
        "headers": {},
    }

    return api_gateway_event

@pytest.fixture
def mock_valid_event_valid_date():
    api_gateway_event = {
        "httpMethod": "GET",
        "queryStringParameters": {"date": "2024-01-01"},
        "headers": {},
    }
    return api_gateway_event

@pytest.fixture
def context():
    @dataclass
    class LambdaContext:
        function_name: str = "test"
        aws_request_id: str = MOCK_INTERACTION_ID
        invoked_function_arn: str = (
            "arn:aws:lambda:eu-west-1:123456789101:function:test"
        )

    return LambdaContext()


@pytest.fixture
def set_env(monkeypatch):
    monkeypatch.setenv("AWS_REGION", REGION_NAME)
    monkeypatch.setenv("BUCKET_NAME", MOCK_BUCKET)