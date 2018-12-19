terraform {
  required_version = ">= 0.11.7"

  backend "s3" {
    encrypt = "true"
  }
}
