variable "account_s3_bucket_name" {}
variable "account_s3_bucket_region" {}
variable "keybase_username" {}

variable "account_id" {}

 /* Global Data points serving as variables */
data "aws_ami" "centos" {
  most_recent = true
   filter {
    name   = "product-code"
    values = ["aw0evgkw8e5c1q413zgy5pjce"]
  }
}