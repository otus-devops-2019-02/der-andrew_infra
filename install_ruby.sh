#!/bin/bash

echo "---=== Ruby install in progress... ===---"
sudo apt update
sudo apt install -y ruby-full ruby-bundler build-essential
ruby -v
bundler -v
