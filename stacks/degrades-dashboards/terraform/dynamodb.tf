resource "aws_dynamodb_table" "degrades_message_table" {
  name = "${var.degrades_message_table}_${var.environment}"
  hash_key = "Timestamp"
  billing_mode = "PAY_PER_REQUEST"
  attribute {
    name = "Timestamp"
    type = "N"
  }
}

data "aws_iam_policy_document" "degrades_message_table_access" {
  statement {
    actions = [
      "dynamodb:BatchGetItem",
      "dynamodb:BatchWriteItem",
      "dynamodb:ConditionCheckItem",
      "dynamodb:PutItem",
      "dynamodb:DescribeTable",
      "dynamodb:DeleteItem",
      "dynamodb:GetItem",
      "dynamodb:Scan",
      "dynamodb:Query",
      "dynamodb:UpdateItem"
    ]
    resources = ["${aws_dynamodb_table.degrades_message_table.arn}"]
  }
}