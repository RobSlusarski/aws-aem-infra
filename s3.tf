resource "aws_s3_bucket" "frontend_bucket" {
    bucket = "${var.www_domain_name}"
    acl = "private"
    force_destroy = true

/*
  lifecycle_rule {
    enabled  = true
    id     = "expire_all_files"

    expiration {
        days = 10
      }
*/

// old inline policy, replaced with s3_oai_read_policy
/*  policy = <<EOF
{
  "Id": "bucket_policy_site",
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "bucket_policy_site_main",
      "Action": [
        "s3:GetObject"
      ],
      "Effect": "Allow",
       "Resource": "arn:aws:s3:::${var.www_domain_name}/*",

      "Principal": "*"
    }
  ]
}
EOF
*/
//        "Resource": "arn:aws:s3:::${var.www_domain_name}/*",

    website {
        index_document = "index.html"
        error_document = "index.html"
    }

    tags = {
        Name = "Dev Journaler Frontend"
        Build = "Auto - CICD"
    }

    versioning {
        enabled = false
    }

    cors_rule {
      allowed_headers = ["*"]
      allowed_methods = ["GET", "HEAD"]
      allowed_origins = ["*"]
      max_age_seconds = 86400
    }

}

/*
locals {
  src_dir = "$HOME"
  content_type_map = {
    html        = "text/html",
    js          = "application/javascript",
    css         = "text/css",
    svg         = "image/svg+xml",
    jpg         = "image/jpeg",
    ico         = "image/x-icon",
    png         = "image/png",
    gif         = "image/gif",
    pdf         = "application/pdf"
  }
}

resource "aws_s3_bucket_object" "upload-index-html" {
  for_each = fileset(local.src_dir,"*.html")
  bucket = "${var.www_domain_name}"
  key     = each.value
  acl = "public-read"
  source = "${local.src_dir}/${each.value}"
  etag = filemd5("${local.src_dir}/${each.value}")
  content_type  = lookup(local.content_type_map, regex("\\.(?P<extension>[A-Za-z0-9]+)$", each.value).extension, "application/octet-stream")
//    content_type  = "text/html"
}*/

resource "aws_s3_bucket_object" "upload-index-html" {
  bucket = "${var.www_domain_name}"
  key     = "index.html"
  acl = "public-read"
  source = "index.html"
  etag = filemd5("index.html")
  content_type  = "text/html"
  depends_on = [aws_s3_bucket.frontend_bucket]
}

resource "aws_s3_bucket_public_access_block" "s3_block_public_access" {
  bucket = aws_s3_bucket.frontend_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
  depends_on = [aws_s3_bucket_object.upload-index-html]
}

resource "aws_cloudfront_origin_access_identity" "frontend_oai" {
  comment = "Frontend Origin Access Identity"
}

data "aws_iam_policy_document" "s3_oai_read_policy" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.frontend_bucket.arn}/*"]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.frontend_oai.iam_arn]
    }
  }
}

resource "aws_s3_bucket_policy" "s3_oai_asset_bucket_policy" {
  bucket = aws_s3_bucket.frontend_bucket.id
  policy = data.aws_iam_policy_document.s3_oai_read_policy.json
  depends_on = [aws_s3_bucket_object.upload-index-html]
}

