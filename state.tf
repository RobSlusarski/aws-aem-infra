terraform{
    backend "s3" {
        bucket = "aem-infra-tf-states"
        key = "global/s3/terraform_cicd.tfstate"
        region = "ap-southeast-2"
    }
}