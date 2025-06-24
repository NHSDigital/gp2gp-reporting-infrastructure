import os

from tests.mocks.sqs_messages.degrades import MOCK_FIRST_DEGRADES_MESSAGE, MOCK_COMPLEX_DEGRADES_MESSAGE
from utils.utils import get_key_from_date, calculate_number_of_degrades, is_degrade, extract_degrades_payload

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
        assert is_degrade(file.read())


def test_is_degrade_with_file_not_degrades_message():
    with open('tests/mocks/mixed_messages/01-DOCUMENT_RESPONSES-01.json', 'r') as file:
        assert is_degrade(file.read()) == False


def test_extract_degrades_payload_simple_message():
    payload = MOCK_FIRST_DEGRADES_MESSAGE["payload"]

    actual = extract_degrades_payload(payload)
    expected = [{"MEDICATION": "CODE"}]
    assert actual == expected


def test_extract_degrades_payload_complex_message():
    payload = MOCK_COMPLEX_DEGRADES_MESSAGE["payload"]

    actual = extract_degrades_payload(payload)
    expected = [{"MEDICATION": "CODE"}, {"RECORD_ENTRY": "CODE"}, {"NON_DRUG_ALLERGY": "CODE"}]
    assert actual == expected