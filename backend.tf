terraform {
  backend "s3" {
    bucket         = "lptest-s3-backend"
    key            = "state/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    assume_role = {
      role_arn       = "arn:aws:iam::381492019105:role/LptestS3BackendRole"
    }
    dynamodb_table = "lptest-s3-backend"
  }
}