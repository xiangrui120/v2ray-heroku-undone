FROM debian:sid

RUN apt update -y \
	&& apt upgrade -y \
	&& apt install -y wget curl ntpdate unzip lsof cron procps

RUN mkdir /etc/v2ray \
	&& mkdir /etc/caddy
	&& mkdir /www
ADD entrypoint.sh /etc/v2ray/entrypoint.sh
RUN chmod +x /etc/v2ray/entrypoint.sh
CMD /etc/v2ray/entrypoint.sh