import json
import pytest
from datetime import datetime
from degrades_message_receiver.main import lambda_handler
from tests.mocks.sqs_messages.degrades import MOCK_FIRST_DEGRADES_MESSAGE, MOCK_SECOND_DEGRADES_MESSAGE
from tests.mocks.sqs_messages.document_response import DOCUMENT_RESPONSE
from models.degrade_message import DegradeMessage
from pydantic import ValidationError


def test_degrades_message_receiver_handles_single_degrade_message(set_env, context, mock_table):
    event = {"Records": [{"body": json.dumps(MOCK_FIRST_DEGRADES_MESSAGE)}]}
    timestamp = int(datetime.fromisoformat(MOCK_FIRST_DEGRADES_MESSAGE["eventGeneratedDateTime"]).timestamp())

    lambda_handler(event, context)

    response = mock_table.get_item(Key={"Timestamp": timestamp,
                                            "MessageId": MOCK_FIRST_DEGRADES_MESSAGE["eventId"]})

    expected = DegradeMessage.model_validate(
        {"timestamp": timestamp, "message_id": MOCK_FIRST_DEGRADES_MESSAGE["eventId"], "event_type": MOCK_FIRST_DEGRADES_MESSAGE["eventType"]})

    actual = DegradeMessage.model_validate(response["Item"])

    assert actual == expected


def test_degrades_message_receiver_handles_more_than_one_degrade_message(set_env, context, mock_table):
    event = {"Records": [{"body": json.dumps(MOCK_FIRST_DEGRADES_MESSAGE)},
                         {"body": json.dumps(MOCK_SECOND_DEGRADES_MESSAGE)}]}
    timestamp1 = int(datetime.fromisoformat(MOCK_FIRST_DEGRADES_MESSAGE["eventGeneratedDateTime"]).timestamp())
    timestamp2 = int(datetime.fromisoformat(MOCK_SECOND_DEGRADES_MESSAGE["eventGeneratedDateTime"]).timestamp())

    lambda_handler(event, context)
    response = mock_table.scan()

    assert len(response["Items"]) == 2
    expected = [DegradeMessage.model_validate({"timestamp": timestamp1, "message_id": MOCK_FIRST_DEGRADES_MESSAGE["eventId"], "event_type": MOCK_FIRST_DEGRADES_MESSAGE["eventType"]}),
                DegradeMessage.model_validate({"timestamp": timestamp2, "message_id": MOCK_SECOND_DEGRADES_MESSAGE["eventId"], "event_type": MOCK_SECOND_DEGRADES_MESSAGE["eventType"]})]

    actual = [DegradeMessage.model_validate(response["Items"][1]), DegradeMessage.model_validate(response["Items"][0])]

    assert actual == expected


def test_degrades_message_receiver_throws_error_message_not_degrades(set_env, context, mock_table):
    event = {"Records": [{"body": json.dumps(DOCUMENT_RESPONSE)},]}
    with pytest.raises(ValidationError):
        lambda_handler(event, context)
