from moto import mock_aws
import boto3
from datetime import datetime
from utils.utils import extract_degrades_payload
from models.degrade_message import DegradeMessage
from degrades_daily_summary.main import lambda_handler

from tests.mocks.sqs_messages.degrades import MOCK_COMPLEX_DEGRADES_MESSAGE, MOCK_FIRST_DEGRADES_MESSAGE, \
    MOCK_SIMPLE_DEGRADES_MESSAGE

degrades_messages = [MOCK_COMPLEX_DEGRADES_MESSAGE, MOCK_FIRST_DEGRADES_MESSAGE, MOCK_SIMPLE_DEGRADES_MESSAGE]


@mock_aws
def test_degrades_daily_summary_lambda_get_degrade_data_from_dynamodb(set_env, context, mock_table, mocker):
    mock_query = mocker.patch.object(mock_table, "query")

    degrade_lines = [
        DegradeMessage(timestamp=int(datetime.fromisoformat(message["eventGeneratedDateTime"]).timestamp()), message_id=message["eventId"],
                       event_type=message["eventType"], degrades=extract_degrades_payload(message["payload"])) for message in
        degrades_messages]

    for degrade in degrade_lines:
        DegradeMessage.model_validate(degrade)
        mock_table.put_item(Item=degrade.model_dump(by_alias=True, exclude={"event_type"}))

    lambda_handler(event={}, context=context)

    mock_query.assert_called()


