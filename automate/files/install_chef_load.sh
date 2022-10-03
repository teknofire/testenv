#!/bin/bash

set -euo pipefail

HAB_LICENSE=accept hab pkg install chef/chef-load -bf

chef-load init > chef-load.toml

# chef-load start -c chef-load.toml -n 1000 -a 100 -i 60 --data_collector_url "https://localhost/data-collector/v0/"

cat << EOF > /etc/systemd/system/chef-load.service
[Unit]
Description=Chef load testing tool
After=network.target

[Service]
ExecStart=chef-load start --config /etc/chef-load/chef_load.toml
Type=simple
PIDFile=/tmp/chef_load.pid
Restart=always
ExecReload=/bin/kill -HUP $MAINPID
KillMode=process
Restart=on-failure
LimitNOFILE=infinity

[Install]
WantedBy=default.target
EOF


mkdir -p /etc/chef-load || true
chmod 755 /etc/chef-load

mkdir /var/log/chef-load || true
chown hab:hab /var/log/chef-load
chown -R hab:hab /var/log/chef-load

mv /tmp/chef-load/* /etc/chef-load/
chown root:root /etc/chef-load/chef-load.toml
chmod 600 /etc/chef-load/chef-load.toml

systemctl daemon-reload
systemctl start chef-load
systemctl enable chef-load
