FROM python:3.7-stretch

RUN apt-get update -y \
	&& apt-get install -y unzip \
	&& python3 -V \
	&& pip3 install requests -U

ADD worker /worker

CMD chmod -R +x /worker

CMD python3 /worker/main.py