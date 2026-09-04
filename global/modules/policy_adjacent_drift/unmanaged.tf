resource "aws_s3_bucket" "compliance_target" {
  bucket = "ice-bucket-${random_id.bucket_suffix.hex}"
}

resource "aws_s3_bucket_public_access_block" "initial" {
  bucket = aws_s3_bucket.compliance_target.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
