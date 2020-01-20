cd /worker
chmod -R +x /worker
echo "v2ray config:"
cat ./v2ray/config.json
echo "caddy config:"
cat ./caddy/Caddyfile

./v2ray/v2ray &
./caddy/caddy -conf ./caddy/Caddyfile