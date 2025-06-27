from moto import mock_aws
from degrades_daily_summary.main import lambda_handler

from tests.mocks.sqs_messages.degrades import MOCK_COMPLEX_DEGRADES_MESSAGE, MOCK_FIRST_DEGRADES_MESSAGE, \
    MOCK_SIMPLE_DEGRADES_MESSAGE

degrades_messages = [MOCK_COMPLEX_DEGRADES_MESSAGE, MOCK_FIRST_DEGRADES_MESSAGE, MOCK_SIMPLE_DEGRADES_MESSAGE]

@mock_aws
def test_degrades_daily_summary_lambda_queries_dynamo(set_env, context, mock_dynamo_service, mock_table, mock_valid_event_valid_date):

    lambda_handler(mock_valid_event_valid_date, context)
    mock_dynamo_service.query.assert_called()






