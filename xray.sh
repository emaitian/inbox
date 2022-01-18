#!/bin/bash
echo
echo -e "\033[49;37;7m install xray \033[0m"
echo -----------------------------------
wget https://github.com/XTLS/Xray-install/raw/main/install-release.sh
bash install-release.sh
chmod a+w /var/log/xray/*.log
rm /usr/local/etc/xray/config.json
echo -n "uuid: "
read uuid
cat > /usr/local/etc/xray/config.json << EOF
{
  "log": {
    "loglevel": "warning",
    "access": "/var/log/xray/access.log",
    "error": "/var/log/xray/error.log"
  },

  "dns": {
    "servers": [
      "https+local://1.1.1.1/dns-query",
      "localhost"
    ]
  },

  "routing": {
    "domainStrategy": "AsIs",
    "rules": [
      {
        "type": "field",
        "ip": [
          "geoip:private"
        ],
        "outboundTag": "block"
      },

      {
        "type": "field",
        "domain": [
          "geosite:category-ads-all"
        ],
        "outboundTag": "block"
      }
    ]
  },

  "inbounds": [
    {
      "port": 443,
      "protocol": "vless",
      "settings": {
        "clients": [
          {
            "id": "$uuid",
            "flow": "xtls-rprx-direct",
            "level": 0,
            "email": "admin@yourdomain.com"
          }
        ],
        "decryption": "none",
        "fallbacks": [
          {
            "dest": 8080
          }
        ]
      },
      "streamSettings": {
        "network": "tcp",
        "security": "xtls",
        "xtlsSettings": {
          "allowInsecure": false,
          "minVersion": "1.2",
          "alpn": ["http/1.1"],
          "certificates": [
            {
              "certificateFile": "/home/cert/fullchain.crt",
              "keyFile": "/home/cert/nevie.xyz.key"
            }
          ]
        }
      }
    }
  ],

  "outbounds": [
    {
      "tag": "direct",
      "protocol": "freedom"
    },
    
    {
      "tag": "block",
      "protocol": "blackhole"
    }
  ]
}
EOF
