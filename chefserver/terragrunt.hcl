include {
  path = find_in_parent_folders()
}

dependency "vpc" {
  config_path = "../vpc"
  skip_outputs = true
}
