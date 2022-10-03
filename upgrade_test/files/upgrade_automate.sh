#!/bin/bash

set -xeuo pipefail

aib_url="https://s3.ap-southeast-2.amazonaws.com/automate-4.x/automate-latest.aib"
aib_bundle=/tmp/automate-latest.aib

cli_url="https://s3.ap-southeast-2.amazonaws.com/automate-4.x/chef-automate"

tmpdir=$(mktemp -d -t automate_upgrade-XXXXXXXXX)

cleanup() {
    status=$?
    [ -d $tmpdir ] && rm -rf $tmpdir
    exit $status
}

trap 'cleanup' ERR

pushd $tmpdir > /dev/null
    #HAB_LICENSE=accept hab pkg install jayvikramsharma/automate-cli/0.1.0/20220830111535 -f
    #cp $(hab pkg path jayvikramsharma/automate-cli)/bin/chef-automate ./chef-automate-dev
    curl https://packages.chef.io/files/dev/latest/chef-automate-cli/chef-automate_linux_amd64.zip | gunzip - > /tmp/chef-automate-dev && chmod +x /tmp/chef-automate-dev

    if [ ! -f $aib_bundle ]; then
        /tmp/chef-automate-dev airgap bundle create --channel dev $aib_bundle
    fi

    echo "Restoring previous backup before attempting to do upgrade"
    # /tmp/chef-automate-dev backup restore

    /tmp/chef-automate-dev version

    echo "Ready to perform upgrade"
    echo "Run the following command: /tmp/chef-automate-dev upgrade run --airgap-bundle ${aib_bundle} --major"
    #/tmp/chef-automate-dev upgrade run --airgap-bundle ./bundle-upgrade.aib --major
popd

cleanup
