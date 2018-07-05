FROM debian:sid

RUN apt update -y \
	&& apt upgrade -y \
	&& apt install -y wget curl ntpdate unzip lsof cron procps

RUN mkdir /etc/v2ray \
	&& mkdir /www
ADD entrypoint.sh /etc/v2ray/entrypoint.sh
RUN chmod +x /etc/v2ray/entrypoint.sh
RUN bash /etc/v2ray/entrypoint.sh

ADD cmd.sh /cmd.sh
RUN chmod +x /cmd.sh
CMD /cmd.sh

RUN echo "$PORT"
RUN cat /etc/v2ray/config.json
RUN cat /usr/local/caddy/Caddyfile
RUN service caddy status