from moto import mock_aws
from degrades_daily_summary.main import lambda_handler

@mock_aws
def test_degrades_daily_summary_lambda_queries_dynamo(set_env, context, mock_dynamo_service, mock_table, mock_scheduled_event):

    lambda_handler(mock_scheduled_event, context)
    mock_dynamo_service.query.assert_called()


# @mock_aws
# def test_degrades_daily_summary_uses_trigger_date_to_query_dynamo(set_env, context, mock_dynamo_service, mock_table, mock_scheduled_event):
#
#     lambda_handler(mock_scheduled_event, context)
#     mock_dynamo_service.query.assert_called_with(key="Timestamp", condition=simple_message_timestamp, table=mock_table.table_name)






