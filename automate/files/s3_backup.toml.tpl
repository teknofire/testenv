[global.v1.backups]
  location = "s3"
[global.v1.backups.s3.bucket]
  # name (required): The name of the bucket
  name = "${bucket_name}"

  # endpoint (required): The endpoint for the region the bucket lives in for Automate Version 3.x.y
  # endpoint (required): For Automate Version 4.x.y, use this https://s3.amazonaws.com
  endpoint = "https://s3.amazonaws.com"

  # base_path (optional):  The path within the bucket where backups should be stored
  # If base_path is not set, backups will be stored at the root of the bucket.
  # base_path = "<base path>"
[deployment.v1.svc]
  channel = "current"
  upgrade_strategy = "none"
