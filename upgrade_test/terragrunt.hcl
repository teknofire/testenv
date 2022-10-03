include {
  path = find_in_parent_folders()
}

dependency "vpc" {
  config_path = "../vpc"
  skip_outputs = true
}

dependency "automate" {
  config_path = "../automate"
}

inputs = {
  automate_public_dns = dependency.automate.outputs.automate_public_dns
}
