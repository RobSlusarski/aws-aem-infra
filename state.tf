terraform{
    backend "s3" {
        bucket = "aem-infra-tf-states/global/s3"
        key = "terraform_cicd.tfstate"
        region = "ap-southeast-2"
    }
}