resource "aws_cloudfront_distribution" "frontend_cloudfront" {
  comment = "Journaler Frontend auto"
  enabled = true
  wait_for_deployment = false
  default_root_object = "index.html"
 
 custom_error_response {
      error_caching_min_ttl = 10
      error_code = 400
      response_code = 200
      response_page_path = "/index.html"
  }
 custom_error_response {
      error_caching_min_ttl = 10
      error_code = 403
      response_code = 200
      response_page_path = "/index.html"
  }
 custom_error_response {
      error_caching_min_ttl = 10
      error_code = 404
      response_code = 200
      response_page_path = "/index.html"
  }


  web_acl_id = ""
  is_ipv6_enabled = true

  origin {
    domain_name = aws_s3_bucket.frontend_bucket.bucket_regional_domain_name
  //  origin_id   = "Static content from S3: ${aws_s3_bucket.frontend_bucket.bucket_name}"
  origin_id   = "S3-media-bucket"
     s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.frontend_oai.cloudfront_access_identity_path
    }
  }

origin {
    domain_name = aws_elb.elb.dns_name
    origin_id   = "backend-elb"
    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
}


  //viewer_certificate {
  //  cloudfront_default_certificate = true
  viewer_certificate {
  //  acm_certificate_arn = aws_acm_certificate.cert.arn
      acm_certificate_arn = "arn:aws:acm:us-east-1:684954863761:certificate/07ac7b25-4104-4944-a2bd-8d407121506b"
    ssl_support_method  = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

 // depends_on = [
 //   aws_acm_certificate_validation.cert-validation
 // ]
  
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  default_cache_behavior {
    allowed_methods = ["GET", "HEAD", "OPTIONS"]
    cached_methods  = ["GET", "HEAD", "OPTIONS"]
    compress        = true
    default_ttl     = 30 * 24 * 60 * 60

    forwarded_values {
      query_string = true

      cookies {
        forward = "none"
      }
    }

    max_ttl                = 30 * 24 * 60 * 60 
    min_ttl                = 0
  //  target_origin_id       = "${var.www_domain_name}"
    target_origin_id = "S3-media-bucket"
    viewer_protocol_policy = "redirect-to-https"
  }

ordered_cache_behavior {
	path_pattern     = "/api*"
	allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
	cached_methods   = ["GET", "HEAD"]
	target_origin_id = "backend-elb"

	default_ttl = 0
	min_ttl     = 0
	max_ttl     = 0

	forwarded_values {
		query_string = true
		cookies {
			forward = "all"
		}
	}

	viewer_protocol_policy = "redirect-to-https"
}

  aliases = ["${var.www_domain_name}"]

}