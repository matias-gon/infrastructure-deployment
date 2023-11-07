terraform {
  backend "s3" {
    encrypt                 = "true"
    bucket                  = "terraform-s3-state-846521"
    dynamodb_table          = "terraform-state-lock-dynamo"
    key                     = "tfstate/terraform.tfstate"
    region                  = "us-west-2"
  }
}
