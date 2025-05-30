import os
from main import calculate_number_of_degrades, lambda_handler


def test_calculate_number_of_degrades():
    folder_path = 'tests/mocks/mixed_messages'
    json_files = [f for f in os.listdir(folder_path) if f.endswith('.json')]

    result = calculate_number_of_degrades(path=folder_path, files=json_files)
    assert result == 5

def test_lambda_handler_throws_400_no_query_string(mock_invalid_call_without_date, context):
    expected = {'statusCode': 400}

    result = lambda_handler(mock_invalid_call_without_date, context)
    assert result == expected

