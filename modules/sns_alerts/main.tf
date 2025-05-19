variable "email_address" {}

resource "aws_sns_topic" "login_alerts" {
  name = "ConsoleLoginAlerts"
}

resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.login_alerts.arn
  protocol  = "email"
  endpoint  = var.email_address
}

output "topic_arn" {
  value = aws_sns_topic.login_alerts.arn
}