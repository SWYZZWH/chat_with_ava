# package
# compress is necessary due to the slow network
tar czvf package.tar.gz build/web backend systemd

remote_ip=$(cat assets/ip_address.txt)
clash_config_url=$(cat clash_config_url.txt)
echo $clash_config_url
echo $remote_ip

# transfer
scp package.tar.gz ubuntu@"$remote_ip":~/
scp upgrade.sh ubuntu@"$remote_ip":~/

# deploy
ssh ubuntu@"$remote_ip"