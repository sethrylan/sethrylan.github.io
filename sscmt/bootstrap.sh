#!/bin/sh
set -e

apt-get update
apt-get install -y ruby-full curl
gem update
mkdir -p /opt/sscmt/
curl -L https://sethrylan.org/files/sscmt.rb --output /opt/sscmt/sscmt.rb
chmod +x /opt/sscmt/sscmt.rb
