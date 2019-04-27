FROM debian:sid

RUN apt update -y \
    	&& apt upgrade -y \
    	&& apt install -y wget unzip qrencode

ADD entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
CMD /entrypoint.sh
