FROM python:3.8-slim-bullseye
MAINTAINER Guenter Bailey

RUN apt-get update && \
	apt-get install -y git nano && \
	rm -rf /var/lib/apt/lists/* && \
	pip install git+https://github.com/akpw/mktxp

RUN mkdir -p /home/mktxp/mktxp && \
    useradd -M -d /home/mktxp -s /bin/bash mktxp

WORKDIR /home/mktxp

COPY config/_mktxp.conf /home/mktxp/mktxp/_mktxp.conf
COPY config/mktxp.conf /home/mktxp/mktxp/mktxp.conf
RUN chown -R mktxp:mktxp /home/mktxp

USER mktxp

EXPOSE 49090
ENTRYPOINT ["/usr/local/bin/mktxp"]
CMD ["export"]
