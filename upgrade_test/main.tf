provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}

terraform {
  backend "local" {}
}

resource "null_resource" "upgrade_automate" {
  connection {
    user  = "ubuntu"
    host  = var.automate_public_dns
    agent = true
  }

  triggers = {
    install_automate_sha = sha256(file("files/upgrade_automate.sh"))
  }

  provisioner "file" {
    source = "files/latest_semver_modified.json"
    destination = "/tmp/latest_semver_modified.json"
  }

  provisioner "file" {
    source = "files/upgrade_automate.sh"
    destination = "/tmp/upgrade_automate.sh"
  }

  provisioner "remote-exec" {
    inline = [
        "chmod u+x /tmp/upgrade_automate.sh",
        "sudo /tmp/upgrade_automate.sh"
    ]
  }
}
