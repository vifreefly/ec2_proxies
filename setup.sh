#!/bin/bash

# Update system
sudo apt update

# Install goproxy
curl -L https://raw.githubusercontent.com/snail007/goproxy/master/install_auto.sh | sudo bash

# Define settings variables
USER_NAME=$1
PROXY_TYPE=$2
PROXY_PORT=$3
PROXY_USER=$4
PROXY_PASSWORD=$5

# Define service command
if [ -n "$PROXY_USER" ] && [ -n "$PROXY_PASSWORD" ]; then
  COMMAND="${PROXY_TYPE} -t tcp -p '0.0.0.0:${PROXY_PORT}' -a '${PROXY_USER}:${PROXY_PASSWORD}'"
else
  COMMAND="${PROXY_TYPE} -t tcp -p '0.0.0.0:${PROXY_PORT}'"
fi

# Create systemd service
sudo echo "[Unit]
Description=Proxy server
Requires=network.target

[Service]
Type=simple
User=${USER_NAME}
WorkingDirectory=/home/${USER_NAME}
ExecStart=/bin/bash -lc '/usr/bin/proxy ${COMMAND}'
TimeoutSec=15
Restart=always

[Install]
WantedBy=multi-user.target" > /etc/systemd/system/proxy.service

# Enable service
sudo systemctl daemon-reload
sudo systemctl enable proxy.service
sudo systemctl start proxy.service

# Print status
sudo systemctl status proxy.service --no-pager
