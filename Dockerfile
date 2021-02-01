# https://github.com/zerotier/ZeroTierOne/blob/master/ext/installfiles/linux/zerotier-containerized/Dockerfile
## NOTE: to retain configuration; mount a Docker volume, or use a bind-mount, on /var/lib/zerotier-one

FROM debian:buster-slim as builder

# Add ENV DEBIAN_FRONTED to avoid Redline or Dialog error Msg
ENV DEBIAN_FRONTEND noninteractive

## Supports x86_64, x86, arm, and arm64

RUN apt-get update && apt-get install -y curl gnupg
RUN apt-key adv --keyserver ha.pool.sks-keyservers.net --recv-keys 0x1657198823e52a61  && \
    echo "deb http://download.zerotier.com/debian/buster buster main" > /etc/apt/sources.list.d/zerotier.list
RUN apt-get update && apt-get install -y zerotier-one=1.6.2

############################################

FROM debian:buster-slim as zerotier-one
LABEL version="1.6.2"
LABEL description="Containerized ZeroTier One Moon for use on CoreOS or other Docker-only Linux hosts."
LABEL maintainer="Franz Yan <franzyang@gmail.com>"

# ZeroTier relies on UDP port 9993
EXPOSE 9993/udp

RUN mkdir -p /var/lib/zerotier-one
COPY --from=builder /usr/sbin/zerotier-cli /usr/sbin/zerotier-cli
COPY --from=builder /usr/sbin/zerotier-idtool /usr/sbin/zerotier-idtool
COPY --from=builder /usr/sbin/zerotier-one /usr/sbin/zerotier-one
COPY startup.sh /startup.sh

RUN chmod 0755 /startup.sh
ENTRYPOINT ["/startup.sh"]
