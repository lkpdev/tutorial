terraform {
  backend "s3" {
    bucket         = "lptest-s3-backend"
    key            = "state/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
  }
}