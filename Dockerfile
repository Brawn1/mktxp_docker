FROM python:3.9-slim-bookworm
LABEL maintainer="Guenter Bailey" \
      version="v1.2.11" \
      description="MKTXP is a Prometheus Exporter for Mikrotik RouterOS devices."

RUN apt-get update && \
	apt-get install -y git nano && \
	rm -rf /var/lib/apt/lists/*

RUN pip install -U pip && \
	pip install git+https://github.com/akpw/mktxp@v1.2.11

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
