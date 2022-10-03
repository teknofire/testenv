#!/bin/bash
set -euo pipefail

# wait till cloud-init has finished setting up repos
until [[ -f /var/lib/cloud/instance/boot-finished ]]; do
  sleep 1
done

echo $(curl -s http://169.254.169.254/latest/meta-data/public-hostname) | xargs sudo hostnamectl set-hostname

# Install additional requirements
sudo apt-get update
sudo apt-get install -y python3-pip
sudo pip install awscli

# Get spot instance request tags to tags.json file
aws --region $1 ec2 describe-spot-instance-requests --spot-instance-request-ids $2 --query 'SpotInstanceRequests[0].Tags' > tags.json
RESULT=$?

if [ $RESULT == 0 ]; then
  # Set instance tags from tags.json file
  aws --region $1 ec2 create-tags --resources $3 --tags file://tags.json && rm -rf tags.json
else
  echo "Failed to get spot request tags!"
  exit $RESULT
fi
