# Bootstrap your AWS account with Terraform

<!-- TOC -->

- [Bootstrap your AWS account with Terraform](#bootstrap-your-aws-account-with-terraform)
    - [Purpose](#purpose)
    - [Intial setup](#intial-setup)
    - [How to use](#how-to-use)
        - [Required manual steps](#required-manual-steps)
        - [Provided TF code for bootstrapping IAM groups + users](#provided-tf-code-for-bootstrapping-iam-groups--users)
    - [Running terraform](#running-terraform)
    - [Directory structure](#directory-structure)
    - [Setup for a new application](#setup-for-a-new-application)
    - [Encrypting and decrypting secrets and first time passwords for `iam_users`](#encrypting-and-decrypting-secrets-and-first-time-passwords-for-iamusers)
        - [Setting up Keybase](#setting-up-keybase)
        - [Decrypting encrypted passwords and secrets for iam_users](#decrypting-encrypted-passwords-and-secrets-for-iamusers)
    - [Key rotations using Terraform](#key-rotations-using-terraform)
    - [Todo](#todo)
    - [References, resources and inspirations](#references-resources-and-inspirations)
    - [Contributing](#contributing)
    - [Copyright](#copyright)

<!-- /TOC -->

## Purpose

An opinionated template to bootstrap an AWS account for IaC (Infrastructure as Code).  This solution can also be used for an existing account. This project defines conventions to organize your AWS infra as code. Both to help those starting with terraform + AWS, and provide some tips and shortcuts to help make the transition for people already on the terraform + AWS path.

One of the major goals here is to use as much as terraform as possible to bootstrap the account and only fulfill the minimal requirements using `aws-cli` or manual intervention to get started with the Infra as Code. With only one manual step and a very small shell script that leverages the `aws-cli`, terraform is being used to do all the heavy lifting such as creating IAM users, VPCs, etc.

## Intial setup

Requirements:

- python 3.7.0 (use [pyenv](https://github.com/pyenv/pyenv) and use this [cheatsheet](https://fijiaaron.wordpress.com/2015/06/18/using-pyenv-with-virtualenv-and-pip-cheat-sheet/) for pyenv if needed)
- [aws-cli 1.15.64](https://docs.aws.amazon.com/cli/latest/userguide/installing.html)

## How to use

1. [download the code](https://api.github.com/repos/skrunchtech/terraform-aws-bootstrap/zipball/master) and unzip
2. Run the manual steps outlined in the next section
3. Run the code in `terraform/global/` if you agree with [what it does](#what-it-does) (or optionally edit/delete those files and use the structure provided)
4. Start coding in terraform

### Required manual steps

- Create the `opsuser_cli` through the aws ui-console using the root user.  The `administrator` policy must be attached to this new user.  Further manipulation on this user can and should be done via terraform or cli
- updating a credentials file with the profile for the newly created user following the [recommended guidelines by AWS](https://docs.aws.amazon.com/cli/latest/userguide/cli-config-files.html).
- Run the `bootstrap.sh` script which will create
    - the remote state bucket and enable versioning on the bucket
    - the dynamodb table `tf_lock` for locking remote state
> Note:  The shell script requires AWS credentials to be stored properly.  If the credentials are not under the `[default]` section of the credentials file, then the profile name will be acquired from an environment variable `AWS_PROFILE`. In addition, the shell script requires `STATE_BUCKET` environment variable to be set with the name of the bucket where the remote state should be stored.  Example to run this script: `STATE_BUCKET="my-tf-state-bucket" AWS_PROFILE="cd-opsuser" ./bootstrap.sh`
- Set up the `backend.conf` file in the common folder by running `STATE_BUCKET="my-tf-state-bucket" LOCK_TABLE="my-dynamo-db-lock-table" make generate-conf`.  This will create a new `backend.conf` file in `./common` folder which will be used to setup the backend for state files.
- Finally, populate the `common/terraform.tfvars` with appropriate variables as well

Example:

```bash
$ cd <ROOT of this repo>
$ export STATE_BUCKET="my-tf-state-bucket"
$ export AWS_PROFILE="my-aws-profile"
$ ./bootstrap.sh
$ make generate-conf
```

### Provided TF code for bootstrapping IAM groups + users

The sample code in `terraform/global/` setups select IAM groups and provides code samples on using these groups.  If the described IAM config is not desired, clean up to replace the `iam_groups.tf` and `iam_users.tf` with your own variations.
<a name="what-it-does"></a>What it does:

- Creates three IAM groups: `admin`, `admin_read_only`, `developer`
- Provides code snippets to create members for these groups in `iam_groups.tf`
- Attach the appropriate IAM policies to these groups
- Example code snippets on creating users in `iam_users.tf`

## Running terraform

All terraform commands can be run with the commands defined in the makefiles.  The `common` folder contains a `_makefile` that's inherited by all other makefiles. Access the help menu and the provided commands by running `make help` in the root or in any other subfolder with a `Makefile` present.
These commands require `AWS_PROFILE` environment variable to be present or will output an error if this is omitted.  Please make sure your credentials that allow running terraform commands are present in a "profile" in `~/.aws/credentials` file. Example:

```
[cd-opsuser]
aws_access_key_id = <YOUR ACCESS KEY>
aws_secret_access_key = <YOUR SECRET KEY>
```

With the example credentials file above, run all make commands similar to the following example: `AWS_PROFILE="cd-opsuser" make plan`
> TIP: Making a bash alias such as `alias cdmake='AWS_PROFILE="cd-opsuser" make'` can allow you to simply run `cdmake plan`

## Directory structure

A standardized directory structure is very important to keep the terraform code organized. A separate folder for each environment and also for global tf configuration can be very useful.  The directory structure in this repo allows segregating apps by environment and AWS regions. The suggested structure is shown below:

```
 $ tree
.
├── Makefile
├── README.md
├── bin
│   ├── terraform-0.11.7
│   └── terraform-0.11.8
├── bootstrap.sh
├── common
│   ├── Makefile.example
│   ├── _makefile
│   ├── account-vars.tf
│   ├── backend.tf
│   └── provider-us-east-1.tf
├── ignore_file
└── terraform
    ├── apps
    │   └── api
    │       └── dev
    │           └── us-east-1
    │               ├── Makefile
    │               ├── main.tf
    │               ├── output.tf
    │               └── vars.tf
    ├── databases
    │   └── db_api
    │       └── dev
    │           └── us-east-1
    │               ├── Makefile
    │               ├── main.tf
    │               ├── output.tf
    │               └── vars.tf
    └── global
        ├── Makefile
        ├── README.md
        ├── account-vars.tf
        ├── backend.tf
        ├── iam_groups.tf
        ├── iam_users.tf
        ├── output.tf
        └── provider.tf

```

## Setup for a new application

1. Create a new folder in the tree `terraform/apps/<app_name>/<env>/<region>`
2. Create `main.tf`, `output.tf`, `vars.tf` files
3. Write a `Makefile` (please see `makefile.example` file in the `common` folder, you can simply copy that Makefile.example file and adjust)
4. symlink `account-vars.tf`, `backend.tf`, `provider-<REGION>.tf` from the `common` folder into your application folder. (If you forget to do that, the first time you run any make command from the provided makefile.example file, these files will be symlinked for you, remember to modify the provider-file name in the example Makefile to the region you need.

## Encrypting and decrypting secrets and first time passwords for `iam_users`

### Setting up Keybase

Use [keybase](https://keybase.io) to encrypt all passwords and secrets when provisioning IAM users through terraform.  To use keybase, simply setup an account and then provide the keybase user in terraform.

### Decrypting encrypted passwords and secrets for iam_users

- Run: `make output`

Example output:

```
 $ cdmake output
CD /Users/amalhotra/workspace/skrunch/terraform/global && /Users/amalhotra/workspace/skrunch/bin/terraform-0.11.8 output
amalhotra_access_key_v1 = [
    AKIWRANDOMACCESSJW5NM4A
]
amalhotra_encrypted_secret_key_v1 = [
    wcBMA/BtTaUN4SdzSCSgOzYBgSRGIf1fwgGj0VPC6UB9fERqpN92noeX/IB53ew7a/hRrGl7LfC0yiR7PJDxooMjopbdXAK9i48dfk+UYVdvBRxeRCAF0umRandomEncryptedSecretKey0hVufvd6FuMIeOEQaGX1eMxDvkqMsQY7MFnvpys4jn+AV8CeQv+bAETYCQKTcjPNE0sDLmvs75u/BiCFdF7WWdK47lFo0UOmWmLidLgamZAfOhhOj4bGEDls4UUj4Pbgm+F2DeDe4h52gzjg7eULIwTk9njUhbzYYTluojeC3OwizXqhDFAFdadasfFDfdfW35/'SHZKABK4GzkLdgMZcYp7jb0X3eKNfruHuKGPIAH4QhSAA==
]
```

- Run: `make output-secret`

Example output:

```
 $ cdmake output-secret

Decrypt an encrypted key or password using keybase
Example to type for the following question: username_encrypted_secret_key_v1

Decrypt target: amalhotra_encrypted_secret_key_v1
rpop6gTdSomeRandomAlphaNumericKey62I+rbQafeW7
```

## Key rotations using Terraform

- adding [name]_v[version_number] e.g. `amalhotra_v2`
- switching output to [name]_v[version_number]
- once app is updated
- removing the previous version

See [terraform/global/README.md](https://github.com/skrunchtech/canndollar-terraform/tree/master/terraform/global) for a detailed example on how to rotate keys the right way.

## Todo

- adding new applications can be easily automated
- Add some more cookie cutter AWS configurations that can help in bootstrapping a new AWS account (VPCs, subnets, security groups, etc)

## References, resources and inspirations

 - https://gist.github.com/prwhite/8168133#gistcomment-976470
 - https://gist.github.com/saurabh-hirani/a94046c65f141eb2d7ee666fa2a21c72#file-terraformmakefile
 - https://github.com/pgporada/terraform-makefile/blob/master/Makefile
 - http://jamesdolan.blogspot.com/2009/10/color-coding-makefile-output.html

## Contributing

If you would like to contribute to this repository, please fork this repo and send a pull request.

## Copyright

Copyright 2018, Skrunch Technologies Inc.
For license, see LICENSE.
