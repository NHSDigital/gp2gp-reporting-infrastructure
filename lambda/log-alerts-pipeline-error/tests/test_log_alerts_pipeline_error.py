import json
import os

import boto3
import pytest
import requests
from moto import mock_aws

from main import create_slack_message, SsmSecretManager, send_slack_alert, lambda_handler


@pytest.fixture
def set_environment(monkeypatch):
    monkeypatch.setenv("CLOUDWATCH_DASHBOARD_URL", "https:cloudwatch")
    monkeypatch.setenv("SLACK_CHANNEL_ID_PARAM_NAME", "slack_channel_id_param_name")
    monkeypatch.setenv("SLACK_BOT_TOKEN_PARAM_NAME", "slack_token_param_name")


@pytest.fixture
def mock_ssm_client():
    with mock_aws():
        conn = boto3.client("ssm", region_name="eu-west-2")
        conn.put_parameter(Name="slack_channel_id_param_name", Value="slack_channel_id", Type="String")
        conn.put_parameter(Name="slack_token_param_name", Value="slack_token", Type="String")
        yield conn


@pytest.fixture
def mock_ssm(mock_ssm_client):
    service = SsmSecretManager(mock_ssm_client)
    yield service


def read_json(filename: str) -> str:
    filepath = os.path.join(os.path.dirname(__file__), filename)
    with open(filepath, "r") as file:
        file_content = file.read()
    return json.loads(file_content)


def test_logs_alert_pipeline_error_lambda_handler_happy_path(mock_ssm, mocker, set_environment):
    mock_send_slack_alert = mocker.patch("main.send_slack_alert")
    lambda_handler(None, None)

    mock_send_slack_alert.assert_called_with(channel_id="slack_channel_id", bot_token="slack_token")


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