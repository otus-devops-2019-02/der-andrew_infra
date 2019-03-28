#!/bin/bash
set -e

echo "---=== Ruby install in progress... ===---"
apt update
apt install -y ruby-full ruby-bundler build-essential
ruby -v
bundler -v
