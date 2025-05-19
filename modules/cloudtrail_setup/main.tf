variable "cloudtrail_role_arn" {}
variable "sns_topic_arn" {}

resource "aws_s3_bucket" "trail_bucket" {
  bucket        = "cloudtrail-logs-${random_id.suffix.hex}"
  force_destroy = true
}

resource "random_id" "suffix" {
  byte_length = 4
}

resource "aws_cloudwatch_log_group" "trail" {
  name              = "/aws/cloudtrail/account-activity"
  retention_in_days = 30
}

resource "aws_cloudtrail" "main" {
  name                          = "account-activity-trail"
  s3_bucket_name                = aws_s3_bucket.trail_bucket.bucket
  include_global_service_events = true
  is_multi_region_trail        = true
  enable_log_file_validation   = true
  is_logging                   = true
  cloud_watch_logs_group_arn   = "${aws_cloudwatch_log_group.trail.arn}:*"
  cloud_watch_logs_role_arn    = var.cloudtrail_role_arn
}

resource "aws_cloudwatch_log_metric_filter" "console_login" {
  name           = "ConsoleLogin"
  log_group_name = aws_cloudwatch_log_group.trail.name

  pattern = "{ $.eventName = \"ConsoleLogin\" }"

  metric_transformation {
    name      = "ConsoleLoginCount"
    namespace = "CloudTrailMetrics"
    value     = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "console_login_alarm" {
  alarm_name          = "ConsoleLoginDetected"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "ConsoleLoginCount"
  namespace           = "CloudTrailMetrics"
  period              = 60
  statistic           = "Sum"
  threshold           = 1

  alarm_description = "Alarm for AWS Console login"
  alarm_actions     = [var.sns_topic_arn]
}