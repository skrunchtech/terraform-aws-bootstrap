.EXPORT_ALL_VARIABLES:
TERRAFORM_VERSION := 0.11.8
DIR := $(shell pwd)
TOPDIR := $(shell git rev-parse --show-toplevel)

ifndef TOPDIR
 	TOPDIR := .
endif

include $(TOPDIR)/common/_makefile