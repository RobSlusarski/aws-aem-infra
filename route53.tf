// Below creates a new hosted zone
//resource "aws_route53_zone" "zone" {
//  name = "${var.root_domain_name}"
//}

// This Route53 record will point at our CloudFront distribution.
resource "aws_route53_record" "www" {
//  zone_id = "${aws_route53_zone.zone.zone_id}"
//  name    = "${var.www_domain_name}"
  zone_id = "Z03943543RPPTTYTVFR1W"
  type    = "CNAME"
  name = "journaler-dev-auto"
  records = ["${aws_cloudfront_distribution.frontend_cloudfront.domain_name}"]
//    name                   = "${aws_cloudfront_distribution.frontend_cloudfront.domain_name}"
//  evaluate_target_health = false
 ttl = "300"
}