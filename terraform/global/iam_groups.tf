/* IAM GROUPS */
resource "aws_iam_group" "admin" {
  name = "admin"
  path = "/"
}

resource "aws_iam_group" "admin_readonly" {
  name = "admin_read_only"
  path = "/"
}

resource "aws_iam_group" "developer" {
  name = "developer_group"
  path = "/"
}

/* GROUP Membership */
resource "aws_iam_group_membership" "full_admins" {
  name = "admin_team"

  users = []

  group = "${aws_iam_group.admin.name}"
}

resource "aws_iam_group_membership" "read_only_admins" {
  name  = "read_only_admin_team"
  users = []
  group = "${aws_iam_group.admin_readonly.name}"
}

resource "aws_iam_group_membership" "developers" {
  name  = "developers"
  users = []
  group = "${aws_iam_group.developer.name}"
}

/* IAM GROUPS AWS POLICY ATTACHMENTS */
resource "aws_iam_group_policy_attachment" "admin_policy" {
  group      = "${aws_iam_group.admin.name}"
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_iam_group_policy_attachment" "admin_read_only_policy" {
  group      = "${aws_iam_group.admin_readonly.name}"
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

resource "aws_iam_group_policy_attachment" "developer_s3_policy" {
  group      = "${aws_iam_group.developer.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_group_policy_attachment" "developer_iam_policy" {
  group      = "${aws_iam_group.developer.name}"
  policy_arn = "arn:aws:iam::aws:policy/IAMUserChangePassword"
}
