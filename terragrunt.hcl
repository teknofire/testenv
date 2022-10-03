terraform {
  extra_arguments "common_var" {
    commands = [
      "apply",
      "plan",
      "import",
      "push",
      "destroy",
      "refresh"
    ]

    arguments = [
      "-var-file=${get_terragrunt_dir()}/${path_relative_from_include()}/common/common.tfvars"
    ]
  }
}

remote_state {
  backend = "local"
  config = {
    path = "${get_terragrunt_dir()}/../state/${path_relative_to_include()}/terraform.tfstate"
  }
}

generate "ami" {
  path      = "ami.tf"
  if_exists = "overwrite"
  contents = <<EOF
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-*-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

EOF
}
