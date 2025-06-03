import json
import os
from utils.utils import get_key_from_date, calculate_number_of_degrades, is_degrade

def test_get_key_from_date():
    date = "2020-01-01"
    assert get_key_from_date(date) == "2020/01/01"


def test_calculate_number_of_degrades():
    folder_path = 'tests/mocks/mixed_messages'
    json_files = [f for f in os.listdir(folder_path) if f.endswith('.json')]

    result = calculate_number_of_degrades(path=folder_path, files=json_files)
    assert result == 5


def test_is_degrade_with_degrade_message():
    with open('tests/mocks/mixed_messages/01-DEGRADES-01.json', 'r') as file:
        assert is_degrade(file)


def test_is_degrade_with_file_not_degrades_message():
    with open('tests/mocks/mixed_messages/01-DOCUMENT_RESPONSES-01.json', 'r') as file:
        assert is_degrade(file) == False
