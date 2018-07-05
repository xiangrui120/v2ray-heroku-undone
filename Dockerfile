FROM debian:sid

RUN apt update -y \
	&& apt upgrade -y \
	&& apt install -y wget curl ntpdate unzip lsof cron

ADD entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
CMD /entrypoint.sh
RUN service v2ray status
RUN cat /etc/v2ray/config.json
RUN cat /usr/local/caddy/Caddyfile