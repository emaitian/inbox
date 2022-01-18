#!/bin/bash
wget "https://raw.githubusercontent.com/emaitian/proxy/main/web.sh"
wget "https://raw.githubusercontent.com/emaitian/inbox/main/trojan-go.sh"
chmod +x *.sh
bash web.sh
bash trojan-ws-tls.sh
