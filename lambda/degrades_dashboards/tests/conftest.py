from dataclasses import dataclass

import pytest

MOCK_INTERACTION_ID = "88888888-4444-4444-4444-121212121212"

@pytest.fixture
def mock_invalid_call_without_date():
    api_gateway_event = {
        "httpMethod": "GET",
        "queryStringParameters": {},
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