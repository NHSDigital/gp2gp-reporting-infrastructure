moved {
  from = aws_s3_bucket_notification.reports_generator_s3_object_created[0]
  to   = aws_s3_bucket_notification.reports_generator_s3_object_created
}
