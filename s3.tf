resource "aws_s3_bucket" "bucket" {
    bucket = "cicd-test-bucket-aem-infra"
    acl = "private"

    tags = {
        Name = "CICD Test bucket"
        Build = "Auto - CICD"
    }
}