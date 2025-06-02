import os
from datetime import datetime
from main import calculate_number_of_degrades, lambda_handler


def test_calculate_number_of_degrades():
    folder_path = 'tests/mocks/mixed_messages'
    json_files = [f for f in os.listdir(folder_path) if f.endswith('.json')]

    result = calculate_number_of_degrades(path=folder_path, files=json_files)
    assert result == 5

def test_lambda_handler_throws_400_no_query_string(mock_invalid_event_empty_query_string, context):
    expected = {'statusCode': 400}

    result = lambda_handler(mock_invalid_event_empty_query_string, context)
    assert result == expected

def test_lamda_handler_throws_400_no_date_in_query_string(mock_invalid_event_without_date, context):
    expected = {'statusCode': 400}

    result = lambda_handler(mock_invalid_event_without_date, context)
    assert result == expected

def test_lamda_handler_throws_400_invalid_date_format_in_query_string(mock_invalid_event_invalid_date_format, context):
    expected = {'statusCode': 400}

    result = lambda_handler(mock_invalid_event_invalid_date_format, context)
    assert result == expected


def test_lambda_handler_returns_200(mock_valid_event_valid_date, context):
    expected = {'statusCode': 200}

    result = lambda_handler(mock_valid_event_valid_date, context)
    assert result == expected