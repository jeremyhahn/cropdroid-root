output "bucket" {
    value = var.create_lock_table_only ? var.s3_bucket_name : aws_s3_bucket.remotestate[0].id
}

output "dynamo_table" {
    value = aws_dynamodb_table.remotestate.id
}
