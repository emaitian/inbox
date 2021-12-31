#!/bin/bash
echo
echo -e "\033[49;37;7m 修改时区 \033[0m"
echo -----------------------------------
date -R
rm -rf /etc/localtime
cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
date -R
echo
#
echo -e "\033[49;37;7m 升级 apt \033[0m"
echo -----------------------------------
apt update
echo
#
echo -e "\033[49;37;7m 安装 curl \033[0m"
echo -----------------------------------
apt install curl
echo
#
echo -e "\033[49;37;7m 加载 release.sh \033[0m"
echo -----------------------------------
curl -O https://raw.githubusercontent.com/v2fly/fhs-install-v2ray/master/install-release.sh
echo
#
echo -e "\033[49;37;7m 加载 dat-release.sh \033[0m"
echo -----------------------------------
curl -O https://raw.githubusercontent.com/v2fly/fhs-install-v2ray/master/install-dat-release.sh
echo
#
echo -e "\033[49;37;7m 安装 release.sh \033[0m"
echo -----------------------------------
bash install-release.sh
echo
#
echo -e "\033[49;37;7m 安装 dat-release.sh \033[0m"
echo -----------------------------------
bash install-dat-release.sh
echo
#
echo -e "\033[49;37;7m 输入端口和uuid \033[0m"
echo -----------------------------------
mkdir /usr/local/etc/v2ray
#
echo -n "port: "
read port
echo -n "uuid: "
read uuid
cat > /usr/local/etc/v2ray/config.json << EOF
{
  "inbounds": [
    {
      "port": $port,
      "protocol": "vmess",    
      "settings": {
        "clients": [
          {
            "id": "$uuid",
            "alterId": 64
          }
        ]
      },
      "streamSettings": {
        "network": "tcp",
        "security": "none"
        }
      }
  ],
  "outbounds": [
    {
      "protocol": "freedom",
      "settings": {}
    }
  ]
}
EOF
echo
echo -e "\033[49;37;7m 重启并查看状态 \033[0m"
echo -----------------------------------
systemctl restart v2ray
systemctl status -l v2ray
