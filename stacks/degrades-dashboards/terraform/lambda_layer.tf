resource "aws_lambda_layer_version" "degrades_lambda_layer" {
  layer_name               = "${var.environment}_degrades_lambda_layer"
  compatible_runtimes      = ["python3.12"]
  compatible_architectures = ["x84_64"]
  source_code_hash         = filebase64sha256("${var.degrades_lambda_layer_zip}")
  filename                 = var.degrades_lambda_layer_zip
}

resource "aws_iam_policy" "lambda_layer_policy" {
  name = "${aws_lambda_layer_version.degrades_lambda_layer.layer_name}_policy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "lambda:GetLayerVersion",
          "lambda:ListLayerVersions",
          "lambda:ListLayers"
        ],
        Resource = [
          "${aws_lambda_layer_version.degrades_lambda_layer.arn}:*"
        ]
      }
    ]
  })
}