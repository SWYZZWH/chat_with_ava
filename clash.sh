mkdir clash && cd clash || exit
wget https://github.com/Dreamacro/clash/releases/download/v1.17.0/clash-linux-amd64-v1.17.0.gz
gzip -d clash-linux-amd64-v1.17.0.gz
mv clash-linux-amd64-v1.17.0 clash
chmod +x clash

apt-get update
apt-install wget

# get config
clash_config_url=$(cat clash_config_url.txt)
wget -O config.yml "${clash_config_url}" 2>/dev/null

# start clash in background
./clash -f config.yml &

# configure /etc/environment
if [ -z "${http_proxy}" ]; then
  echo 'http_proxy="http://127.0.0.1:7890/"' | sudo tee -a /etc/environment
  echo 'https_proxy="http://127.0.0.1:7890/"' | sudo tee -a /etc/environment
  echo 'ftp_proxy="http://127.0.0.1:7890/"' | sudo tee -a /etc/environment
  echo 'socks_proxy="socks://127.0.0.1:7891/"' | sudo tee -a /etc/environment
  echo 'no_proxy="localhost,127.0.0.1"' | sudo tee -a /etc/environment
fi

source /etc/environment