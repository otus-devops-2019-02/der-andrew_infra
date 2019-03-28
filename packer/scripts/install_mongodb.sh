#!/bin/bash
set -e

echo "---=== MongoDB install in progress... ===---"
apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv EA312927
bash -c 'echo "deb http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.2 multiverse" > /etc/apt/sources.list.d/mongodb-org-3.2.list'
apt update
apt install -y mongodb-org
systemctl enable mongod 
#systemctl start mongod
#systemctl status mongod 
