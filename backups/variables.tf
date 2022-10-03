variable "default_tags" {
  description = "A list of default tags that will be applied to resources, do not change this here instead modify the values in terraform.tfvars"
  default = {
    X-Application = "wfisher-automate"
    X-Dept = "SCE"
    X-Environment = "test"
    X-Production = "false"
    X-Sleep = "off"
  }
}

variable "override_tags" {
  default = { }
}

variable "vpc_state_path" {
  description = "Relative path to the location of the vpc terraform.tfstate file"
  default = "../state/vpc/terraform.tfstate"
}

variable "aws_profile" {
  description = "AWS Profile to use for credentials"
}

variable "aws_region" {
  default = "us-west-2"
}

variable "namespace" {
  description = "Namespace to apply to names of resources created"
}

variable "aws_key_name" {
  description = "AWS Key name to use for authentication to ec2 instances"
}

variable "ssh_pub_key_path" {
  description = "SSH Public key path"
  default = "../.chef/aws_sshkey.pub"
}
