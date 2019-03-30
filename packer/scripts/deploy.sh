#!/bin/bash
set -e

echo "---=== Application deploy in progress... ===---"
cd ~
git clone -b monolith https://github.com/express42/reddit.git
cd reddit/
bundle install

echo "---=== Installing Pumad service ===---"
tee <<- EOF_SERVICE > /lib/systemd/system/pumad.service
[Unit]
Description=Puma service
After=network.target mongod.service

[Service]
#User=appuser
#Group=appuser
Type=oneshot
WorkingDirectory=/home/appuser/reddit
ExecStart=/usr/local/bin/puma -d
Restart=no
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF_SERVICE

systemctl daemon-reload
systemctl enable pumad
#systemctl status pumad
