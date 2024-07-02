resource "aws_iam_role" "s3_event_notification" {
  name = "${var.name}-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": [
          "lambda.amazonaws.com"
        ]
      },
      "Effect": "Allow"
    }
  ]
}
EOF

  inline_policy {
    name = "${var.name}-policy"

    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [{
        Action   = ["sns:Publish"]
        Effect   = "Allow"
        Resource = local.notification_arn
      }]
    })
  }

  tags = var.tags
}

resource "aws_lambda_function" "s3_event_notification" {
  filename         = var.lambda_filename
  function_name    = var.name
  role             = aws_iam_role.s3_event_notification.arn
  handler          = "lambda_function.lambda_handler"
  source_code_hash = filebase64sha256(var.lambda_filename)
  runtime          = var.runtime
  tags             = var.tags

  environment {
    variables = var.lambda_environment_variables
  }
}

resource "aws_lambda_permission" "allow_bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.s3_event_notification.arn
  principal     = "s3.amazonaws.com"
  source_arn    = var.bucket_arn
}

resource "aws_s3_bucket_notification" "bucket_notification" {
    bucket = local.target_bucket

    depends_on = [aws_lambda_permission.allow_bucket]

    lambda_function {
        lambda_function_arn = aws_lambda_function.s3_event_notification.arn
        events              = ["s3:ObjectCreated:*"]
        filter_suffix       = var.filter_suffix
        filter_prefix       = var.filter_prefix
    }
}
