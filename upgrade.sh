#!/usr/bin/env bash

cd ~ || exit
#sudo apt-get update
#sudo apt-get install -y wget

# stop service
# sequence doesn't matter
sudo systemctl stop chat_with_ava_frontend
sudo systemctl stop chat_with_ava_backend
sudo systemctl stop clash

# clean up
sudo rm -rf backend-bak
sudo rm -rf web-bak
sudo rm -rf build
sudo rm -rf systemd-bak

# for rollback
mv backend backend-bak
mv web web-bak
mv systemd systemd-bak

# decompress
tar xzvf package.tar.gz
mv build/web web

## register and start service
sudo cp /home/ubuntu/systemd/* /etc/systemd/system
sudo systemctl daemon-reload
sudo systemctl start chat_with_ava_frontend
sudo systemctl start chat_with_ava_backend

# check and configure proxy
if [ ! -d clash ]; then
    mkdir clash && cd clash || exit
    wget https://github.com/Dreamacro/clash/releases/download/v1.17.0/clash-linux-amd64-v1.17.0.gz
    gzip -d clash-linux-amd64-v1.17.0.gz
    mv clash-linux-amd64-v1.17.0 clash
    chmod +x clash

    # get config
    wget -O config.yml web "$(cat "web/assets/assets/ip_address.txt")" 2>/dev/null

    echo 'http_proxy="http://127.0.0.1:7890/"' | sudo tee -a /etc/environment
    echo 'https_proxy="http://127.0.0.1:7890/"' | sudo tee -a /etc/environment
    echo 'ftp_proxy="http://127.0.0.1:7890/"' | sudo tee -a /etc/environment
    echo 'socks_proxy="socks://127.0.0.1:7891/"' | sudo tee -a /etc/environment
    echo 'no_proxy="localhost,127.0.0.1"' | sudo tee -a /etc/environment

    source /etc/environment
fi

## run proxy
sudo systemctl start clash

## register for auto boot
sudo systemctl enable chat_with_ava_frontend
sudo systemctl enable chat_with_ava_backend
sudo systemctl enable clash