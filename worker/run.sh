cd /worker
chmod -R +x /worker
./v2ray/v2ray &
./caddy/caddy -conf ./caddy/Caddyfile