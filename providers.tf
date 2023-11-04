provider "aws" {
  region = "ap-southeast-2"
  alias = "AU"
}
    
provider "aws" {
  region = "eu-west-2"
  alias = "UK"
}

provider "aws" {
  region = "us-east-1"
  alias = "US"
}