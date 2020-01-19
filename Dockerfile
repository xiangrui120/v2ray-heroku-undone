FROM python:3.7-stretch

ADD worker /worker

ARG AppName=$AppName
ARG Subscribe_Address=$Subscribe_Address
ARG UUID=$UUID
ARG AlterID=$AlterID
ARG V2_Path=$V2_Path
ARG Reverse_Proxy_Path=$Reverse_Proxy_Path

RUN apt-get update -y \
	&& apt-get install unzip -y \
	&& pip3 install requests -U \
	&& cd /worker \
	&& python3 ./deploy.py

CMD /worker/run.sh