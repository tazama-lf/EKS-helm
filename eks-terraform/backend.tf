#####################################
# Terraform State
#####################################

terraform {
  backend "s3" {
    bucket  = "tazama-tf-state"
    key     = "state/terraform.tfstate"
    dynamodb_table = "terraform-lock"
    encrypt = true
    region  = "eu-north-1"
  }
}
