## How to setup a chatgpt mirror site which is accessible worldwide (bypass GFW)

### 1. Buy a server on tencent cloud
If you're under 25, then you can get the server with a discount.

### 2. Set up region and system image
Select regions in China

System image can be any linux distributions, while debian distributions like debian, ubuntu are preferred.

### 3. Set up password or phrase to remote login
reset root password:

https://cloud.tencent.com/document/product/1207/44575

follow this tutorial:

https://cloud.tencent.com/document/product/1207

default username of ubuntu is "ubuntu"!


### TL;DR
just clone this repo, then offer you own clash config url and openai apikey
```json
// $project_root/backend/secrets.json
{
  "open_ai_key": "your key",
  "port": $port_number_you_like # you should open this port
}
```
in $project_root/clash_config_url.txt
```text
your_clash_config_url
```
in $project_root/assets/ip_address.txt
```text
your_clash_config_url
```
Then simply run deploy.sh

### 4. Coding
...


### 5. Deploy
first build web package

in idea, just select build -> Flutter -> Build Web

If you're on mac:

1. Open your MacOS System Preferences.
2. Navigate to Security & Privacy.
3. Switch to the General tab.
4. You should see a message at the bottom about "font-subset" being blocked. Click the button labeled "Allow Anyway."

Next, cp output to ubuntu
```bash
### cd to the root of the project
cd build
tar czf "web.tar.gz" web
scp -r web.tar.gz ubuntu@ip:~/
# enter password 
```

p.s. cp backend to ubuntu 
```bash
cd /Users/zhaoweihao/PycharmProjects/chat_with_ava_backend
sh ./deploy.sh
scp -r backend.tar.gz ubuntu@ip:~/
```

On ubuntu
Run on ubuntu
```bash
tar xvf web.tar.gz
cd web
# sometimes 80 port will be occupied
sudo python3 -m http.server 443 &

tar xvf backend.tar.gz
cd backend
# will launch on 5000
sudo python3 app.py
```


### 6. Set up proxy
Before deploying, the proxy has to be set up first.
https://juzicloud.net/user/tutorial?os=linux&client=clash

```bash
ssh ubuntu@ip
cd ~ && mkdir clash

# get clash
cd clash
wget https://github.com/Dreamacro/clash/releases/download/v1.17.0/clash-linux-amd64-v1.17.0.gz
gzip -d clash-linux-amd64-v1.17.0.gz
mv clash-linux-amd64-v1.17.0 clash
chmod +x clash

# get config
wget -O config.yml https://s.juzicloud.vip/link/kyYNxlz9nAJcAwZX?clash=1&log-level=info 2>/dev/null

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
```

now we break the GFW

### 7. register systemd

```bash
sudo cp /home/ubuntu/systemd/* /etc/systemd/system
sudo systemctl daemon-reload
sudo systemctl start chat_with_ava_frontend
sudo systemctl start chat_with_ava_backend
sudo systemctl start clash
```

for debug
```bash
systemctl is-enabled chat_with_ava_frontend
systemctl is-enabled chat_with_ava_backend
systemctl is-enabled clash
```

### 8. Todo

1. docker
    
    it's hard to pass docker image from US to China

    have to configure docker registry, and it's not stable
    
    docker image is larger than package itself.

2. configure
    
    api key, ip address should be configurable for replacing machine or change ip address

3. domain name and SSL 

4. Frontend functionalities
    
    - support user history (we can simply use local cache, no db necessary)
    - support interrupt
    - disable user input when responding
    - loading animation

5. monitor
    
    for safety and performance

6. CI/CD
   
    ~~login remote without password~~