terraform {
  backend "s3" {
    region         = "us-east-1"
    bucket         = "cropdroid-terraform-remote-state-mgmt"
    key            = "aft.tfstate"
    encrypt        = true
    dynamodb_table = "cropdroid-terraform-remote-state-locks"
  }
}
