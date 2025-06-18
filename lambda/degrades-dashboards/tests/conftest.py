from unittest import mock

import boto3
from dataclasses import dataclass
from moto import mock_aws

import pytest

MOCK_INTERACTION_ID = "88888888-4444-4444-4444-121212121212"
REGION_NAME = "us-east-1"
MOCK_BUCKET = "test-s3-bucket"
MOCK_DEGRADES_MESSAGE_TABLE_NAME = "degrades_messages_table"

MOCK_DEGRADES_MESSAGE_TABLE_ATTRIBUTES = [
    {
        'AttributeName': 'Timestamp',
        'AttributeType': 'N'
    },
    {
        'AttributeName': 'MessageId',
        'AttributeType': 'S'
    },
]

MOCK_DEGRADES_MESSAGE_TABLE_KEY_SCHEMA = [
    {
        'AttributeName': 'Timestamp',
        'KeyType': 'HASH'
    },
    {
        "AttributeName": "MessageId",
        "KeyType": "RANGE"
    }
]

MOCK_FIRST_DEGRADES_MESSAGE = {
    "eventId": "02-DEGRADES-02",
    "eventGeneratedDateTime": "2024-09-20T00:00:00",
    "eventType": "DEGRADES",
    "reportingSystemSupplier": "EMIS",
    "payload": {
        "degrades": [
            {
                "type": "MEDICATION",
                "reason": "CODE",
                "coding": [
                    {
                        "code": "01147001",
                        "system": "UNKNOWN"
                    },
                    {
                        "code": "01147001",
                        "system": "UNKNOWN"
                    }
                ]
            },
            {
                "type": "RECORD_ENTRY",
                "reason": "CODE",
                "coding": [
                    {
                        "code": "oaz1.",
                        "system": "CLINICAL_TERMS_READV3"
                    },
                    {
                        "code": "x001v",
                        "system": "CLINICAL_TERMS_READV3"
                    },
                    {
                        "code": "ga8..",
                        "system": "CLINICAL_TERMS_READV3"
                    }
                ]
            },
            {
                "type": "NON_DRUG_ALLERGY",
                "reason": "CODE",
                "coding": [
                    {
                        "code": "196471000000108",
                        "system": "SNOMED_CT"
                    },
                    {
                        "code": "609328004",
                        "system": "SNOMED_CT"
                    }
                ]
            }
        ]
    }
}

MOCK_SECOND_DEGRADES_MESSAGE = {
  "eventId": "01-DEGRADES-01",
  "eventGeneratedDateTime": "2024-09-20T00:00:00",
  "eventType": "DEGRADES",
  "reportingSystemSupplier": "EMIS",
  "payload": {
    "degrades": [
      {
        "type": "MEDICATION",
        "reason": "CODE",
        "coding": [
          {
            "code": "02543001",
            "system": "UNKNOWN"
          },
          {
            "code": "02543001",
            "system": "UNKNOWN"
          }
        ]
      }
    ]
  }
}

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
def mock_table():
    with mock_aws():
        conn = boto3.resource("dynamodb", region_name=REGION_NAME)
        degrades_table = conn.create_table(TableName=MOCK_DEGRADES_MESSAGE_TABLE_NAME,
                                       KeySchema=MOCK_DEGRADES_MESSAGE_TABLE_KEY_SCHEMA,
                                       AttributeDefinitions=MOCK_DEGRADES_MESSAGE_TABLE_ATTRIBUTES,
                                       BillingMode="PAY_PER_REQUEST", )
        yield degrades_table



@pytest.fixture
def set_env(monkeypatch):
    monkeypatch.setenv("AWS_REGION", REGION_NAME)
    monkeypatch.setenv("REGISTRATIONS_MI_EVENT_BUCKET", MOCK_BUCKET)
    monkeypatch.setenv("DEGRADES_MESSAGE_TABLE", MOCK_DEGRADES_MESSAGE_TABLE_NAME)
