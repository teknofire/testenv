locals {
  orgname = "workshop"
  tags = merge(var.default_tags, var.override_tags)
  s3_backup_config = templatefile("files/s3_backup.toml.tpl", {
    bucket_name = var.s3_backup_bucket
  })
}

provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}

terraform {
  # The configuration for this backend will be filled in by Terragrunt
  backend "local" {}
}

data "terraform_remote_state" "vpc" {
  backend = "local"

  config = {
    path = "${path.module}/${var.vpc_state_path}"
  }
}


resource "aws_instance" "automate" {
  ami      = data.aws_ami.ubuntu.id
  instance_type             = "m5.xlarge"
  key_name                  = var.aws_key_name
  subnet_id                 = data.terraform_remote_state.vpc.outputs.public_subnets[0]
  vpc_security_group_ids    = [data.terraform_remote_state.vpc.outputs.default_sg_id, data.terraform_remote_state.vpc.outputs.http_sg_id]
  iam_instance_profile      = data.terraform_remote_state.vpc.outputs.base_instance_profile_id

  root_block_device {
    volume_type = "gp2"
    volume_size = 50
  }

  lifecycle {
    ignore_changes = [ami]
  }

  tags = merge(
    var.default_tags, tomap({
      "Name" = "${var.namespace}-automate"
    })
  )
}

# module "automate" {
#   source = "../modules/tagged_spot_instance"

#   name      = "automate"
#   namespace = var.namespace

#   ami      = data.aws_ami.ubuntu.id
#   username = "ubuntu"

#   aws_region                = var.aws_region
#   instance_type             = var.instance_type
#   key_name                  = var.aws_key_name
#   subnet_id                 = data.terraform_remote_state.vpc.outputs.public_subnets[0]
#   vpc_security_group_ids    = [data.terraform_remote_state.vpc.outputs.default_sg_id, data.terraform_remote_state.vpc.outputs.http_sg_id]
#   iam_instance_profile      = data.terraform_remote_state.vpc.outputs.base_instance_profile_id
#   role                      = data.terraform_remote_state.vpc.outputs.base_role_id
#   instance_tags             = local.tags
#   instance_root_volume_size = 50
# }

resource "null_resource" "install_automate" {
  depends_on = [aws_instance.automate]

  connection {
    user  = "ubuntu"
    host  = aws_instance.automate.public_dns
    agent = true
  }

  triggers = {
    install_automate_sha = sha256(file("files/install_automate.sh"))
    s3_backup_sha = sha256(local.s3_backup_config)
  }

  provisioner "file" {
    source      = "files/install_automate.sh"
    destination = "/tmp/install_automate.sh"
  }

  provisioner "file" {
    destination = "/tmp/s3_backup.toml"
    content = local.s3_backup_config
  }

  provisioner "file" {
    source = "files/chef-load.toml"
    destination = "/tmp/chef-load.toml"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/install_automate.sh",
      "sudo /tmp/install_automate.sh 3.0.57 dev",
    ]
  }
}
