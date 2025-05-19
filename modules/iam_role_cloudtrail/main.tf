variable "role_name" {}
variable "sns_topic_arn" {}

resource "aws_iam_role" "cloudtrail_role" {
  name = var.role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "cloudwatch" {
  role       = aws_iam_role.cloudtrail_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSCloudTrail_LogDelivery"
}

resource "aws_iam_policy" "sns_publish" {
  name = "${var.role_name}-sns-publish"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = "sns:Publish",
        Resource = var.sns_topic_arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "sns" {
  role       = aws_iam_role.cloudtrail_role.name
  policy_arn = aws_iam_policy.sns_publish.arn
}

output "role_arn" {
  value = aws_iam_role.cloudtrail_role.arn
}