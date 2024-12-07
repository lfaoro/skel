!#/usr/bin/env bash

sudo ufw limit 22/tcp
# allow mosh ports
sudo ufw allow 60000:61000/udp
sudo ufw allow 60000:61000/tcp
sudo ufw enable
