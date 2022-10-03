#!/bin/bash

set -euo pipefail

echo $(curl -s http://169.254.169.254/latest/meta-data/public-hostname) | xargs sudo hostnamectl set-hostname

sysctl -w vm.swappiness=1
sysctl -w vm.dirty_expire_centisecs=30000
sysctl -w net.ipv4.ip_local_port_range='35000 65000'
sysctl -w vm.max_map_count=262144
sysctl -w vm.dirty_expire_centisecs=20000

echo 'never' > /sys/kernel/mm/transparent_hugepage/enabled
echo 'never' > /sys/kernel/mm/transparent_hugepage/defrag

version=${1:-3.0.49}
channel=${2:-current}

# install Chef Automate
if [ ! $(which chef-automate) ]; then
  echo "Installing Chef Automate CLI..."
  curl https://packages.chef.io/files/dev/latest/chef-automate-cli/chef-automate_linux_amd64.zip | gunzip - > chef-automate && chmod +x chef-automate
  # curl https://packages.chef.io/files/current/automate/latest/chef-automate_linux_amd64.zip | gunzip - > chef-automate && chmod +x chef-automate
fi

if [ ! -f /tmp/bundle-${version}.aib ]; then
  echo "Generating airgap bundle for version ${version}"
  ./chef-automate airgap bundle create --channel $channel --version $version /tmp/bundle-${version}.aib
fi

# run setup
if [ ! -f /root/automate.deployed ]; then
  echo "Running chef-automate init-config"
  ./chef-automate init-config --upgrade-strategy none --file ./config.toml

  echo "Running chef-automate deploy"
  ./chef-automate deploy ./config.toml --accept-terms-and-mlsa --product automate --product chef-server --upgrade-strategy none --airgap-bundle /tmp/bundle-${version}.aib

  touch /root/automate.deployed

  mkdir -p /drop || true
  chef-server-ctl org-create test 'Test Org' -f /drop/test-validator.pem
fi

echo "Your Chef Automate2 server is ready!"

HAB_LICENSE=accept hab pkg install chef/chef-load -b

# Set the backup config toml
./chef-automate config patch /tmp/s3_backup.toml

# Starting backup creation
# Skip this for now
#./chef-automate backup create --no-progress
