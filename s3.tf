resource "aws_s3_bucket" "frontend_bucket" {
    bucket = "dev-journaler-auto"
    acl = "private"

  policy = <<EOF
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
       "Resource": "arn:aws:s3:::dev-journaler-auto/*",

      "Principal": "*"
    }
  ]
}
EOF

//        "Resource": "arn:aws:s3:::${frontend_bucket.bucket_name}/*",

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
}

resource "aws_s3_bucket_public_access_block" "block_public_access" {
  bucket = aws_s3_bucket.frontend_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
