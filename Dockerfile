FROM debian:sid

ADD worker /worker

RUN apt-get update -y \
	&& apt-get upgrade -y \
	&& apt-get install -y wget unzip qrencode python3 python3-pip \
	&& python3 -V \
	&& pip3 install requests -U \
	&& cd /worker \
	&& python3 ./deploy.py \

CMD /worker/run.sh