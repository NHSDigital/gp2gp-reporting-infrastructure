import os
from calculate_degrades_lambda import calculate_number_of_degrades


def test_calculate_number_of_degrades():
    folder_path = 'tests/mocks/mixed_messages'
    json_files = [f for f in os.listdir(folder_path)]

    result = calculate_number_of_degrades(json_files)
    assert result == 5