resource "aws_s3_bucket" "app_bucket" {
  bucket = "${var.project}-${var.environment}-app"

  tags = {
    Name        = "${var.project}-${var.environment}-app"
    Project     = var.project
    Environment = var.environment
  }
}

resource "aws_s3_bucket_ownership_controls" "app_bucket" {
  bucket = aws_s3_bucket.app_bucket.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "app_bucket" {
  depends_on = [aws_s3_bucket_ownership_controls.app_bucket]

  bucket = aws_s3_bucket.app_bucket.id
  acl    = var.bucket_acl
}

resource "aws_s3_bucket_public_access_block" "app_bucket" {
  bucket = aws_s3_bucket.app_bucket.id

  block_public_acls       = var.block_public_acls
  block_public_policy     = var.block_public_policy
  ignore_public_acls      = var.ignore_public_acls
  restrict_public_buckets = var.restrict_public_buckets
}

resource "aws_s3_bucket_policy" "cloudfront_access" {
  count = var.enable_cloudfront ? 1 : 0

  bucket = aws_s3_bucket.app_bucket.id
  policy = var.cloudfront_access_policy
}