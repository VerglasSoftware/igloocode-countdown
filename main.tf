provider "aws" {
  region = "eu-west-1"
}

resource "aws_iam_role" "lambda_exec" {
  name = "lambda_discord_bot_exec"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/lambda"
  output_path = "${path.module}/lambda.zip"
}

resource "aws_lambda_function" "discord_updater" {
  function_name = "discord_channel_updater"
  role          = aws_iam_role.lambda_exec.arn
  handler       = "index.handler"
  runtime       = "nodejs18.x"
  filename      = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  environment {
    variables = {
      CHANNEL_ID = var.discord_channel_id
      BOT_TOKEN  = var.discord_bot_token
    }
  }
}

resource "aws_cloudwatch_event_rule" "daily_schedule" {
  name                = "discord-daily-countdown"
  schedule_expression = "cron(0 0 * * ? *)" # Every day at midnight UTC
}

resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.daily_schedule.name
  target_id = "discordCountdownLambda"
  arn       = aws_lambda_function.discord_updater.arn
}

resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.discord_updater.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.daily_schedule.arn
}