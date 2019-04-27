#! /bin/bash -v
if [[ -z "${UUID}" ]]; then
  UUID="4890bd47-5180-4b1c-9a5d-3ef686543112"
  echo "UUID未填,将采用默认UUID${UUID}"
fi

if [[ -z "${AlterID}" ]]; then
  AlterID="10"
  echo "AlterID未填,将采用默认AlterID${AlterID}"
fi

if [[ "${V2_Path}" == '/' ]];then
  V2_Path="/FreeApp"
  echo "路径不能为根路径,将采用默认路径${V2_Path}"
fi

if [[ -z "${V2_Path}" ]]; then
  V2_Path="/FreeApp"
  echo "V2路径未填,将采用默认路径${V2_Path}"
fi

if [[ -z "${V2_QR_Path}" ]]; then
  V2_QR_Code="1234"
fi

if [[ -z "${Anti_Proxy_Path}" ]]; then
  Anti_Proxy_Path="https://www.baidu.com"
fi

rm -rf /etc/localtime
ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
date -R

SYS_Bit="$(getconf LONG_BIT)"
[[ "$SYS_Bit" == '32' ]] && BitVer='_linux_386.tar.gz'
[[ "$SYS_Bit" == '64' ]] && BitVer='_linux_amd64.tar.gz'
echo "您正在使用${SYS_Bit}位系统!"

if [ "$VER" = "latest" ]; then
  V_VER=`wget -qO- "https://api.github.com/repos/v2ray/v2ray-core/releases/latest" | grep 'tag_name' | cut -d\" -f4`
else
  V_VER="v$VER"
fi

mkdir /v2raybin
cd /v2raybin
wget --no-check-certificate -qO 'v2ray.zip' "https://github.com/v2ray/v2ray-core/releases/download/$V_VER/v2ray-linux-$SYS_Bit.zip"
unzip v2ray.zip
rm -rf v2ray.zip
chmod +x /v2ray/*

C_VER=`wget -qO- "https://api.github.com/repos/mholt/caddy/releases/latest" | grep 'tag_name' | cut -d\" -f4`
mkdir /caddybin
cd /caddybin
wget --no-check-certificate -qO 'caddy.tar.gz' "https://github.com/mholt/caddy/releases/download/$C_VER/caddy_$C_VER$BitVer"
tar xvf caddy.tar.gz
rm -rf caddy.tar.gz
chmod +x caddy
# cd /root
# mkdir /wwwroot
# cd /wwwroot

# wget --no-check-certificate -qO 'demo.tar.gz' "https://raw.githubusercontent.com/ki8852/v2ray-heroku-undone/master/demo.tar.gz"
# tar xvf demo.tar.gz
# rm -rf demo.tar.gz

cat <<-EOF > /v2ray/config.json
{
    "log":{
        "loglevel":"warning"
    },
    "inbound":{
        "protocol":"vmess",
        "listen":"127.0.0.1",
        "port":2333,
        "settings":{
            "clients":[
                {
                    "id":"${UUID}",
                    "level":1,
                    "alterId":${AlterID}
                }
            ]
        },
        "streamSettings":{
            "network":"ws",
            "wsSettings":{
                "path":"${V2_Path}"
            }
        }
    },
    "outbound":{
        "protocol":"freedom",
        "settings":{
        }
    }
}
EOF

cat <<-EOF > /caddybin/Caddyfile
http://0.0.0.0:${PORT}
{
	timeouts none
  proxy / ${Anti_Proxy_Path} {
    gzip
  }
	proxy ${V2_Path} localhost:2333 {
		websocket
    without ${V2_Path}
		header_upstream -Origin
	}
}
EOF

cat <<-EOF > /v2ray/vmess.json 
{
    "v": "2",
    "ps": "${AppName}.herokuapp.com",
    "add": "${AppName}.herokuapp.com",
    "port": "443",
    "id": "${UUID}",
    "aid": "${AlterID}",			
    "net": "ws",			
    "type": "none",			
    "host": "",			
    "path": "${V2_Path}",	
    "tls": "tls"			
}
EOF

if [ "$AppName" = "no" ]; then
  echo "不生成二维码"
else
  mkdir /wwwroot/$V2_QR_Path
  vmess="vmess://$(cat /v2raybin/vmess.json | base64 -w 0)" 
  Linkbase64=$(echo -n "${vmess}" | tr -d '\n' | base64 -w 0) 
  echo "${Linkbase64}" | tr -d '\n' > /wwwroot/$V2_QR_Path/index.html
  echo -n "${vmess}" | qrencode -s 6 -o /wwwroot/$V2_QR_Path/v2.png
fi

cd /v2raybin/v2ray-$V_VER-linux-$SYS_Bit
./v2ray &
cd /caddybin
./caddy -conf="Caddyfile"
