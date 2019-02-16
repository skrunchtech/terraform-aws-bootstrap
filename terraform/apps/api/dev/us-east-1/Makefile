USER := api
REGION := us-east-1

.EXPORT_ALL_VARIABLES:
TERRAFORM_VERSION := 0.11.8
TFLINT_VERSION := 0.7.3
TF_S3_PREFIX := regions/$(REGION)/$(USER)
TF_BUCKET_REGION := us-east-1
DIR := $(shell pwd)
TOPDIR := $(shell git rev-parse --show-toplevel)
BACKEND := $(shell ls backend.tf)
PROVIDER := $(shell ls provider.tf)
TFVARSFILE := $(shell ls terraform.tfvars)
ACCOUNTVARS := $(shell ls account-vars.tf)

ifndef TOPDIR
 	TOPDIR := ../../../../../
endif

RELTOPDIR := $(shell python -c 'import os; print(os.path.relpath("$(TOPDIR)", "$(DIR)"))')

ifndef BACKEND
	BACKEND := $(shell ln -s -n -f $(RELTOPDIR)/common/backend.tf backend.tf)
endif

ifndef PROVIDER
	PROVIDER := $(shell ln -s -n -f $(RELTOPDIR)/common/providers/provider-$(REGION).tf provider.tf)
endif

ifndef TFVARSFILE
	TFVARSFILE := $(shell ln -s -n -f $(RELTOPDIR)/common/terraform.tfvars terraform.tfvars)
endif

ifndef ACCOUNTVARS
	ACCOUNTVARS := $(shell ln -s -n -f $(RELTOPDIR)/common/account-vars.tf account-vars.tf)
endif

include $(TOPDIR)/common/_makefile
