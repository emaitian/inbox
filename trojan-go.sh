#!/bin/bash
echo
echo -e "\033[49;37;7m install trojan-go \033[0m"
echo -----------------------------------
mkdir -p /etc/trojan/bin/
wget --no-check-certificate -O /etc/trojan/bin/trojan-go-linux-amd64.zip "https://github.com/p4gefau1t/trojan-go/releases/download/v0.10.6/trojan-go-linux-amd64.zip"
apt install unzip -y
unzip -o -d /etc/trojan/bin /etc/trojan/bin/trojan-go-linux-amd64.zip
echo
#
echo
echo -e "\033[49;37;7m create configuration \033[0m"
echo -----------------------------------
mkdir -p /etc/trojan/conf
cat > /etc/trojan/conf/server.json << EOF
{
    "run_type": "server", 
    "local_addr": "0.0.0.0",
    "local_port": 443,
    "remote_addr": "127.0.0.1",
    "remote_port": 80,
    "log_level": 1,
    "log_file": "",
    "password": ["12356abc"],
    "disable_http_check": false,
    "udp_timeout": 60,
    "ssl": {
        "verify": true,
        "verify_hostname": true, 
        "cert": "/home/cert/fullchain.crt",
        "key": "/home/cert/nevie.xyz.key",
        "key_password": "",
        "cipher": "",
        "curves": "",
        "prefer_server_cipher": false,
        "sni": "nevie.xyz",
        "alpn": [
            "http/1.1"
        ],
        "session_ticket": true,
        "reuse_session": true,
        "plain_http_response": "",
        "fallback_addr": "127.0.0.1",
        "fallback_port": 80,
        "fingerprint": ""
    },
    "websocket": {
        "enabled": true,
        "path": "/random",
        "host": "nevie.xyz"
    }
}
EOF
echo
#
echo -e "\033[49;37;7m create trojan.service \033[0m"
echo -----------------------------------
cat >/etc/systemd/system/trojan.service<< EOF
[Unit]
Description=trojan
Documentation=https://github.com/p4gefau1t/trojan-go
After=network.target

[Service]
Type=simple
StandardError=journal
PIDFile=/usr/src/trojan/trojan/trojan.pid
ExecStart=/etc/trojan/bin/trojan-go -config /etc/trojan/conf/server.json
ExecReload=
ExecStop=/etc/trojan/bin/trojan-go
LimitNOFILE=51200
Restart=on-failure
RestartSec=1s

[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload
