resource "aws_s3bucket" "bucket" {
    bucket = "cicd_test_bucket"
    acl = "private"

    tags = {
        Name = "CICD Test bucket"
        Build = "Auto - CICD"
    }
}