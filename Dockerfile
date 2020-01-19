FROM debian:sid

ADD worker /worker

ENV AppName=${AppName} \
	Subscribe_Address=${Subscribe_Address} \
	UUID=${UUID} \
	AlterID=${AlterID} \
	V2_Path=${V2_Path} \
	Reverse_Proxy_Path=${Reverse_Proxy_Path}

RUN apt-get update -y \
	&& apt-get upgrade -y \
	&& apt-get install -y wget unzip qrencode python3 python3-pip \
	&& python3 -V \
	&& pip3 install requests -U \
	&& cd /worker \
	&& python3 ./deploy.py 

CMD /worker/run.sh