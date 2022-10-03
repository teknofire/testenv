#!/bin/bash

set -xeuo pipefail

tmpdir=$(mktemp -d -t install-XXXXXXXXX)

cleanup() {
    status=$?
    [ -d $tmpdir ] && rm -rf $tmpdir
    exit $status
}

apt update
apt install build-essential -y

pushd $tmpdir > /dev/null

url=https://packages.chef.io/files/stable/chef-server/15.1.7/ubuntu/20.04/chef-server-core_15.1.7-1_amd64.deb
filename=chef-server-core_15.1.7-1_amd64.deb

if [ ! -f /var/opt/opscode/bootstrapped ]; then
    if [ ! -f $filename ]; then
        curl $url -o $filename
        dpkg -i $filename
    fi

    chef-server-ctl reconfigure --chef-license=accept

    chef-server-ctl install chef-manage

    chef-server-ctl reconfigure

    chef-manage-ctl reconfigure --accept-license
fi

mkdir /drop || true
if [ ! -f /drop/admin.pem ]; then
    chef-server-ctl user-create admin admin user admin@localhost.com 'ch3fr0cks' -f /drop/admin.pem
fi

if [ ! -f /drop/test-validator.pem ]; then
    chef-server-ctl org-create test test --association_user admin -f /drop/test-validator.pem
fi

if [ ! -f /drop/tekno.pem ]; then
    chef-server-ctl user-create tekno tekno tekno tekno@localhost.com 'ch3fr0cks' -f /drop/tekno.pem
    chef-server-ctl org-user-add test tekno --admin
fi

if [ ! -f /tmp/chef-workstation_22.7.1006-1_amd64.deb ]; then
    curl -o /tmp/chef-workstation_22.7.1006-1_amd64.deb https://packages.chef.io/files/stable/chef-workstation/22.7.1006/ubuntu/20.04/chef-workstation_22.7.1006-1_amd64.deb
    dpkg -i /tmp/chef-workstation_22.7.1006-1_amd64.deb
fi
