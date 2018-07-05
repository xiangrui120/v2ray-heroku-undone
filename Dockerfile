FROM debian:sid

RUN apt update -y \
	&& apt upgrade -y \
	&& apt install -y wget curl ntpdate unzip lsof cron

RUN bash <(curl https://install.direct/go.sh)
RUN	bash <(curl https://raw.githubusercontent.com/ToyoDAdoubi/doubi/master/caddy_install.sh)

ADD entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
CMD /entrypoint.sh
RUN service caddy status