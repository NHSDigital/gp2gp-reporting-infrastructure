import os
from utils.utils import get_key_from_date, calculate_number_of_degrades

def test_get_key_from_date():
    date = "2020-01-01"
    assert get_key_from_date(date) == "2020/01/01"


def test_calculate_number_of_degrades():
    folder_path = 'tests/mocks/mixed_messages'
    json_files = [f for f in os.listdir(folder_path) if f.endswith('.json')]

    result = calculate_number_of_degrades(path=folder_path, files=json_files)
    assert result == 5