## Global IAM Management

### IAM Users: 
All IAM Users are defined in `iam_users.tf` file.  The secrets keys should be encrypted with keybase.io username in the `vars.tf`

#### Rotating iam keys
- adding [name]_v[version_number] e.g. `username_v2`
- switching output to [name]_v[version_number]
- once app is updated
- removing the previous version

Example: 
The user amalhotra has a key setup in the `iam_users.tf` file: 
```
resource "aws_iam_access_key" "amalhotra_key_v1" {
  user    = "${aws_iam_user.amalhotra.name}"
  pgp_key = "keybase:myUserOnKeybase"
}
```
To rotate this users key without deleting the existing one, add:
```
resource "aws_iam_access_key" "amalhotra_key_v2" {
  user    = "${aws_iam_user.amalhotra.name}"
  pgp_key = "keybase:myUserOnKeybase"
}
```
Note the change in version from `v1` to `v2`. 

In the outputs.tf file, this exists for `v1`:
```
output "amalhotra_access_key_v1" {
  value = ["${aws_iam_access_key.amalhotra_key_v1.id}"]
}

output "amalhotra_encrypted_secret_key_v1" {
  value = ["${aws_iam_access_key.amalhotra_key_v1.encrypted_secret}"]
}
```
Modify the above from `v1` to `v2` without adding brand new outputs.  Run `make plan` and `make apply` to apply these changes.  Decrypt the key with `make output-secret` and once the user is informed of the change or the application key has been updated, remove `v1` from the `iam_users.tf` file and run `make plan` and `make apply` to delete the version 1 of user's access/secret keys.  

### IAM Groups
All IAM Groups are defined in `iam_groups.tf` file.  The file contains groups, membership and policy attachment to the groups. 

### IAM Policies
ALL IAM policies should be defined in `iam_policies_<policy_name>.tf` files.  For example: `iam_policies_full_kinesis.tf`.  Individual files for individual custom policies can be used or if policies are small enough, they can be combined in a longer (as long as the file remains manageable) `iam_policies.tf` file.

### IAM Roles
All IAM Roles should be defined in `iam_roles.tf` files.  For roles with elaborate policy, use `iam_roles_<role_name>.tf`, following a similar pattern to IAM Policies.

### Importing existing users, groups, roles and policies
An existing IAM user or an IAM group can easily be imported by using the import command by terraform.  
```bash
$ terraform import aws_iam_policy.admin_read_only_policy arn:aws:iam::aws:policy/ReadOnlyAccess
$ terraform import aws_iam_user.amalhotra amalhotra
$ terraform import aws_iam_group.admin_read_only Admin_ReadOnly
$ terraform import aws_iam_role.apigateway_to_kinesis apigateway-to-kinesis
```

The above commands would import the group "Admin_ReadOnly" as `admin_read_only`, the user "amalhotra" as `amalhotra`, the policy defined by the given arn as `admin_read_only_policy` and the role named `apigateway-to-kinesis`.  Once a resource is imported, it needs to be defined in the config.  For example, after importing the `admin_read_only` group, it can be defined as 
```
resource "aws_iam_group" "admin_read_only" {
    name = "Admin_ReadOnly"
    path = "/"
}
```

After defining the resource, `make plan` should show no changes to be made.  The group attachments as well as group memberships can be added in the configuration and they will simply add/overwrite the existing group attachments + memberships.  