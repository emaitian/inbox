#!/bin/bash
echo
echo -e "\033[49;37;7m update apt and install nginx \033[0m"
echo -----------------------------------
apt update && apt install nginx -y
echo
#
echo -e "\033[49;37;7m modify nginx.conf && create 80 server \033[0m"
echo -----------------------------------
rm /etc/nginx/nginx.conf
cat > /etc/nginx/nginx.conf << EOF
user www-data;
worker_processes auto;
pid /run/nginx.pid;
include /etc/nginx/modules-enabled/*.conf;

events {
	worker_connections 768;
	# multi_accept on;
}

http {

	##
	# Basic Settings
	##

	sendfile on;
	tcp_nopush on;
	types_hash_max_size 2048;
	# server_tokens off;

	server_names_hash_bucket_size 64;
	# server_name_in_redirect off;

	include /etc/nginx/mime.types;
	default_type application/octet-stream;

	##
	# SSL Settings
	##

	ssl_protocols TLSv1 TLSv1.1 TLSv1.2 TLSv1.3; # Dropping SSLv3, ref: POODLE
	ssl_prefer_server_ciphers on;

	##
	# Logging Settings
	##

	access_log /var/log/nginx/access.log;
	error_log /var/log/nginx/error.log;

	##
	# Gzip Settings
	##

	gzip on;

	# gzip_vary on;
	# gzip_proxied any;
	# gzip_comp_level 6;
	# gzip_buffers 16 8k;
	# gzip_http_version 1.1;
	# gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript;

	##
	# Virtual Host Configs
	##

        server {
                listen 80;
                server_name nevie.xyz;
                root /data/www;
        }

	include /etc/nginx/conf.d/*.conf;
	include /etc/nginx/sites-enabled/*;
}


#mail {
#	# See sample authentication script at:
#	# http://wiki.nginx.org/ImapAuthenticateWithApachePhpScript
#
#	# auth_http localhost/auth.php;
#	# pop3_capabilities "TOP" "USER";
#	# imap_capabilities "IMAP4rev1" "UIDPLUS";
#
#	server {
#		listen     localhost:110;
#		protocol   pop3;
#		proxy      on;
#	}
#
#	server {
#		listen     localhost:143;
#		protocol   imap;
#		proxy      on;
#	}
#}
EOF
systemctl restart nginx
echo
#
echo
echo -e "\033[49;37;7m accept 80 and 443 port \033[0m"
echo -----------------------------------
iptables -A INPUT -p tcp -m tcp --dport 80 -j ACCEPT
iptables -A INPUT -p tcp -m tcp --dport 443 -j ACCEPT
echo
#
echo
echo -e "\033[49;37;7m install git && get a web model \033[0m"
echo -----------------------------------
apt install git -y
git clone  https://github.com/JeannieStudio/Programming.git /data/www
echo
#
echo
echo -e "\033[49;37;7m install cert \033[0m"
echo -----------------------------------
curl https://get.acme.sh | sh -s email=emaitian@gmail.com
~/.acme.sh/acme.sh --issue -d nevie.xyz --nginx
mkdir -p /home/cert
~/.acme.sh/acme.sh --install-cert -d nevie.xyz --fullchain-file /home/cert/fullchain.crt
~/.acme.sh/acme.sh --install-cert -d nevie.xyz --key-file /home/cert/nevie.xyz.key
chmod +r /home/cert/nevie.xyz.key
echo
#
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
        "outboundTag": "direct"
      },

      {
        "type": "field",
        "domain": [
          "geosite:category-ads-all"
        ],
        "outboundTag": "direct"
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
echo
#
echo -e "\033[49;37;7m modify nginx.conf \033[0m"
echo -----------------------------------
rm /etc/nginx/nginx.conf
cat > /etc/nginx/nginx.conf << EOF
user www-data;
worker_processes auto;
pid /run/nginx.pid;
include /etc/nginx/modules-enabled/*.conf;

events {
	worker_connections 768;
	# multi_accept on;
}

http {

	##
	# Basic Settings
	##

	sendfile on;
	tcp_nopush on;
	types_hash_max_size 2048;
	# server_tokens off;

	server_names_hash_bucket_size 64;
	# server_name_in_redirect off;

	include /etc/nginx/mime.types;
	default_type application/octet-stream;

	##
	# SSL Settings
	##

	ssl_protocols TLSv1 TLSv1.1 TLSv1.2 TLSv1.3; # Dropping SSLv3, ref: POODLE
	ssl_prefer_server_ciphers on;

	##
	# Logging Settings
	##

	access_log /var/log/nginx/access.log;
	error_log /var/log/nginx/error.log;

	##
	# Gzip Settings
	##

	gzip on;

	# gzip_vary on;
	# gzip_proxied any;
	# gzip_comp_level 6;
	# gzip_buffers 16 8k;
	# gzip_http_version 1.1;
	# gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript;

	##
	# Virtual Host Configs
	##

    server {
            listen 80;
            server_name nevie.xyz;
            return 301 https://\$http_host\$request_uri;
    }

    server {
            listen 127.0.0.1:8080;
            root /data/www;
            index index.html;
            add_header Strict-Transport-Security "max-age=63072000" always;
    }

	include /etc/nginx/conf.d/*.conf;
	include /etc/nginx/sites-enabled/*;
}


#mail {
#	# See sample authentication script at:
#	# http://wiki.nginx.org/ImapAuthenticateWithApachePhpScript
#
#	# auth_http localhost/auth.php;
#	# pop3_capabilities "TOP" "USER";
#	# imap_capabilities "IMAP4rev1" "UIDPLUS";
#
#	server {
#		listen     localhost:110;
#		protocol   pop3;
#		proxy      on;
#	}
#
#	server {
#		listen     localhost:143;
#		protocol   imap;
#		proxy      on;
#	}
#}
EOF
#
echo -e "\033[49;37;7m restart nginx and xray \033[0m"
echo -----------------------------------
systemctl restart nginx
systemctl restart xray
systemctl status nginx
systemctl status xray
