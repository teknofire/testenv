#!/bin/bash
set -euo pipefail

# wait till cloud-init has finished setting up repos
#until [[ -f /var/lib/cloud/instance/boot-finished ]]; do
#  sleep 1
#done

echo $(curl -s http://169.254.169.254/latest/meta-data/public-hostname) | xargs sudo hostnamectl set-hostname

# Install additional requirements
sudo apt-get update
sudo apt-get install -y python3-pip jq
sudo pip install awscli

AWS_INSTANCE_ID=$(curl http://169.254.169.254/latest/meta-data/instance-id)

echo '${tags}' > tags.json

# Set instance tags
aws --region ${region} ec2 create-tags --resources $AWS_INSTANCE_ID --tags file://tags.json
