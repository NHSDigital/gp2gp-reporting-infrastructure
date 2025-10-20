import os
import json

import pytest
from datetime import datetime

import requests
from main import create_slack_message, SsmSecretManager, send_slack_alert

@pytest.fixture
def set_environment(monkeypatch):
    monkeypatch.setenv("CLOUDWATCH_DASHBOARD_URL", "https:cloudwatch")
    monkeypatch.setenv("SLACK_CHANNEL_ID_PARAM_NAME", "slack_channel_id_param_name")
    monkeypatch.setenv("SLACK_BOT_TOKEN_PARAM_NAME", "slack_token_param_name")

MOCK_SSM_PARAMETER_RESPONSE = {
    "Parameter": {
        "Name": "ssm_parameter_key",
        "Type": "String",
        "Value": "string",
        "Version": 123,
        "Selector": "string",
        "SourceResult": "string",
        "LastModifiedDate": datetime(2015, 1, 1),
        "ARN": "string",
        "DataType": "string",
    }
}

@pytest.fixture
def mock_ssm(mocker):
    mock_ssm = mocker.patch("boto3.client")
    service = SsmSecretManager(mock_ssm)
    mocker.patch.object(service._ssm, "get_parameter")
    yield service

def read_json(filename: str) -> str:
    filepath = os.path.join(os.path.dirname(__file__), filename)
    with open(filepath, "r") as file:
        file_content = file.read()
    return json.loads(file_content)


def test_create_slack_message_template(set_environment):
    expected = read_json("./mock_messages/mock_slack_message.json")
    actual = create_slack_message()

    assert actual == expected

def test_send_slack_message_happy_path(mocker, set_environment):
    mock_post = mocker.patch("main.requests.post")

    slack_message = {
        "channel": "channel_id",
        "blocks": create_slack_message(),
    }

    send_slack_alert(channel_id="channel_id", bot_token="bot_token")

    mock_post.assert_called_with(headers={"Content-Type": "application/json",
                                            "Authorization": "Bearer bot_token"},
                                   url="https://slack.com/api/chat.postMessage",
                                   data=json.dumps(slack_message))

def test_send_slack_message_http_error_logs_error(mocker, set_environment, caplog):
    mock_post = mocker.patch("main.requests.post")
    mock_post.side_effect = requests.exceptions.HTTPError()

    send_slack_alert(channel_id="channel_id", bot_token="bot_token")

    expected_message = "Failed to send slack alert"

    assert caplog.records[-1].msg == expected_message
