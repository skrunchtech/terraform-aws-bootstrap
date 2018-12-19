/* Uncomment the following outputs to get the outputs of the user you created in iam_users file
* The three outputs are standard and can be used in conjunction with the code in iam_users.tf file
* They provide with the users password and secret key (encrypted with the keybase user's pgp key)
* And a non encrypted Access key. 
* Replace 'username' with the name of the user to be created

output "username_password" {
  value = "${aws_iam_user_login_profile.username.encrypted_password}"
}

output "username_access_key_v1" {
  value = ["${aws_iam_access_key.username_key_v1.id}"]
}

output "username_encrypted_secret_key_v1" {
  value = ["${aws_iam_access_key.username_key_v1.encrypted_secret}"]
}

*/
