locals {
  orgname = "workshop"
  tags = merge(var.default_tags, var.override_tags)
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

resource "aws_instance" "chefserver" {
  ami      = data.aws_ami.ubuntu.id
  instance_type             = "m5.xlarge"
  key_name                  = var.aws_key_name
  subnet_id                 = data.terraform_remote_state.vpc.outputs.public_subnets[0]
  vpc_security_group_ids    = [data.terraform_remote_state.vpc.outputs.default_sg_id, data.terraform_remote_state.vpc.outputs.http_sg_id]
  iam_instance_profile      = data.terraform_remote_state.vpc.outputs.base_instance_profile_id

  root_block_device {
    volume_type = "gp2"
    volume_size = 20
  }

  lifecycle {
    ignore_changes = [ami]
  }

  tags = merge(
    var.default_tags, tomap({
      "Name" = "${var.namespace}-chefserver"
    })
  )
}

# module "chefserver" {
#   source = "../modules/tagged_spot_instance"

#   name      = "chefserver"
#   namespace = var.namespace

#   ami      = data.aws_ami.ubuntu.id
#   username = "ubuntu"

#   aws_region                = var.aws_region
#   instance_type             = var.instance_type
#   key_name                  = var.aws_key_name
#   subnet_id                 = data.terraform_remote_state.vpc.outputs.public_subnets[0]
#   vpc_security_group_ids    = [aws_security_group.nonrootports.id, data.terraform_remote_state.vpc.outputs.default_sg_id, data.terraform_remote_state.vpc.outputs.http_sg_id]
#   iam_instance_profile      = data.terraform_remote_state.vpc.outputs.base_instance_profile_id
#   role                      = data.terraform_remote_state.vpc.outputs.base_role_id
#   instance_tags             = local.tags
#   instance_root_volume_size = 20
# }

resource "aws_security_group" "nonrootports" {
  name        = "${var.namespace}_nonrootports"
  description = "Allow nonroot http ports in"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id

  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    cidr_blocks     = concat(
                        data.terraform_remote_state.vpc.outputs.allowed_cidrs,
                        [data.terraform_remote_state.vpc.outputs.cidr]
                      )
    security_groups = [data.terraform_remote_state.vpc.outputs.default_sg_id]
  }
  ingress {
    from_port       = 8443
    to_port         = 8443
    protocol        = "tcp"
    cidr_blocks     = concat(
                        data.terraform_remote_state.vpc.outputs.allowed_cidrs,
                        [data.terraform_remote_state.vpc.outputs.cidr, "0.0.0.0/0"]
                      )
    security_groups = [data.terraform_remote_state.vpc.outputs.default_sg_id]
  }
}


resource "null_resource" "install_cs" {
  depends_on = [aws_instance.chefserver]

  connection {
    user  = "ubuntu"
    host  = aws_instance.chefserver.public_dns
    agent = true
  }

  triggers = {
    install_cs_sha = sha256(file("files/install_cs.sh"))
  }

  provisioner "file" {
    source = "files/install_cs.sh"
    destination = "/tmp/install_cs.sh"
  }

  provisioner "remote-exec" {
    inline = [
        "chmod u+x /tmp/install_cs.sh",
        "sudo /tmp/install_cs.sh"
    ]
  }
}
