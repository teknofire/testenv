include {
  path = find_in_parent_folders()
}

dependency "vpc" {
  config_path = "../vpc"
  skip_outputs = true
}

dependency "backups" {
  config_path = "../backups"
}

inputs = {
  s3_backup_bucket = dependency.backups.outputs.s3_backup_bucket
}
