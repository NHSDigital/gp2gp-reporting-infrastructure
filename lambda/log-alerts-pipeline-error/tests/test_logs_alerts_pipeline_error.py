import os
import json

import pytest
from main import create_slack_message

@pytest.fixture
def set_environment(monkeypatch):
    monkeypatch.setenv("CLOUDWATCH_DASHBOARD_URL", "https:cloudwatch")

def read_json(filename: str) -> str:
    filepath = os.path.join(os.path.dirname(__file__), filename)
    with open(filepath, "r") as file:
        file_content = file.read()
    return json.loads(file_content)

def test_create_slack_message_template(set_environment):
    expected = read_json("./mock_messages/mock_slack_message.json")
    actual = create_slack_message()

    assert actual == expected