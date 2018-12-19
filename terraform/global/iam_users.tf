/* Use the below as a sample code to setup quick users 
* This will create a user with the name "username"
* Create a login profile (allowing an initial passport to be set )
* Use Keybase Username for encryption of the secret key and the password
* Set a version1 Access key and Secret key, setting way for easy key rotations
* Replace "username" with the user you want to create
* Ensure that the keybase_username variable contains the keybase user you want to encrypt with
******** 

resource "aws_iam_user" "username" {
  name          = "username"
  path          = "/"
  force_destroy = true
}

resource "aws_iam_user_login_profile" "username" {
  user    = "${aws_iam_user.username.name}"
  pgp_key = "keybase:${var.keybase_username}"
}

resource "aws_iam_access_key" "username_key_v1" {
  user    = "${aws_iam_user.username.name}"
  pgp_key = "keybase:${var.keybase_username}"
}

*/