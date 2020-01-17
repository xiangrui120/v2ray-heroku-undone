FROM debian:sid

RUN apt update -y \
	&& apt upgrade -y \
	&& apt install -y wget unzip qrencode python3 python3-pip \
	&& python3 -V \
	&& pip3 install requests -U

#ADD entrypoint.sh /entrypoint.sh
#RUN chmod +x /entrypoint.sh
#CMD /entrypoint.sh
