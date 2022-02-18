systemctl stop xray
rm /usr/local/etc/xray/config.json
cat > /usr/local/etc/xray/config.json << EOF
{
  "log": {
    "loglevel": "warning",
    "access": "/var/log/xray/access.log",
    "error": "/var/log/xray/error.log"
  },
  "inbounds": [
    {
      "port": 443,
      "protocol": "vless",
      "settings": {
        "clients": [
          {
            "id": "62e0d0c1-077a-4f2d-a822-aabf571333b2",
            "level": 0,
            "email": "admin@yourdomain.com"
          }
        ],
        "decryption": "none",
        "fallbacks": [
          {
            "dest": 80
          }
        ]
      },
      "streamSettings": {
        "network": "ws",
        "security": "tls",
        "tlsSettings": {
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
      "protocol": "freedom"
    }
  ]
}
EOF
systemctl start xray
