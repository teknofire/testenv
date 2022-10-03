locals {
  tags = merge(var.default_tags, var.override_tags)
  backup_bucket = "${var.namespace}-automate-backup"
}

provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}

terraform {
  # The configuration for this backend will be filled in by Terragrunt
  backend "local" {}
}

resource "aws_s3_bucket" "automate_backup" {
  bucket = local.backup_bucket
  acl    = "private"

  lifecycle {
    prevent_destroy = true
  }
}
