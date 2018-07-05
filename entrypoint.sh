#! /bin/bash

function check_time(){
	rm -rf /etc/localtime
	cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
	ntpdate time.nist.gov
}

function install_v2ray_caddy(){
	mkdir /etc/v2ray && cd /etc/v2ray
	wget http://storage.googleapis.com/v2ray-docker/v2ray 
	wget http://storage.googleapis.com/v2ray-docker/v2ctl
	wget http://storage.googleapis.com/v2ray-docker/geoip.dat
	wget http://storage.googleapis.com/v2ray-docker/geosite.dat
	chmod +x v2ray
	chmod +x v2ctl
	cd /root
	wget https://raw.githubusercontent.com/ToyoDAdoubi/doubi/master/caddy_install.sh && bash caddy_install.sh && rm -rf caddy_install.sh
}

function set_v2ray_caddy(){
	if [[ -z "${UserUUID}" ]];then
		UserUUID="c120a2df-c37b-4e73-b0cf-dd29946dabed"
	fi
	if [[ -z "${AlterID}" ]];then
		AlterID="10"
	fi
	if [[ -z "${Path}" ]];then
		Path="/letscrosschinagfw"
	fi
	cat <<-EOF > /etc/v2ray/config.json
{
    "inbound": {
		"listen":"127.0.0.1",
        "port": 10000,
        "protocol": "vmess",
        "settings": {
			"udp": true,
            "clients": [
                {
                    "id": "${UserUUID}",
                    "alterId": ${AlterID}
                }
            ]
		},
		"streamSettings": {
			"network":"ws",
            "wsSettings":{
				"path":"${Path}"
			}
        }
    },
    "outbound": {
        "protocol": "freedom",
        "settings": {}
    },
    "inboundDetour": [],
    "outboundDetour": [
        {
            "protocol": "blackhole",
            "settings": {},
            "tag": "blocked"
        }
    ],
    "routing": {
        "strategy": "rules",
        "settings": {
            "rules": [
                {
                    "type": "field",
                    "ip": [
                        "0.0.0.0/8",
                        "10.0.0.0/8",
                        "100.64.0.0/10",
                        "127.0.0.0/8",
                        "169.254.0.0/16",
                        "172.16.0.0/12",
                        "192.0.0.0/24",
                        "192.0.2.0/24",
                        "192.168.0.0/16",
                        "198.18.0.0/15",
                        "198.51.100.0/24",
                        "203.0.113.0/24",
                        "::1/128",
                        "fc00::/7",
                        "fe80::/10"
                    ],
                    "outboundTag": "blocked"
                }
            ]
        }
    }
}
	EOF
	cat <<-EOF > /usr/local/caddy/Caddyfile
localhost:${PORT}
{
	root /www
	timeouts none
	proxy ${Path} localhost:10000 {
		websocket
		header_upstream -Origin
	}
}
	EOF
}

function set_webindex(){
	cat <<-EOF > /www/index.html
<!DOCTYPE html>
<html>
    <head>
        <title>WorldCDN - Designed by World.Team - herokuapp.com</title>
        <link rel="stylesheet" href="https://fonts.cat.net/css?family=Roboto:300">
        <style>
            html, body {
                height: 100%;
            }
            body {
                margin: 0;
                padding: 0;
                width: 100%;
                display: table;
                font-weight: 100;
                font-family: "Roboto",sans-serif;
            }
            .container {
                text-align: center;
                display: table-cell;
                vertical-align: middle;
            }
            .content {
                text-align: center;
                display: inline-block;
            }
            .title {
                font-size: 96px;
            }
            .textcontent {
                font-size: 50px;
            }
        </style>
    </head>
    <body>
        <div class="container">
            <div class="content">
                <div class="title">WorldCDN for Video</div>
				<br />
				<div class="textcontent">Designed by World.Team</div>
            </div>
        </div>
    </body>
</html>
	EOF
}

function restart_service(){
	service caddy restart
	/etc/v2ray/v2ray --config=/etc/v2ray/config.json&
}
	
function main(){
	check_time
	install_v2ray_caddy
	set_v2ray_caddy
	set_webindex
	restart_service
}