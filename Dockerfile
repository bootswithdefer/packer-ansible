FROM hashicorp/packer:light
MAINTAINER Jesse DeFer <packer-ansible@dotd.com>

RUN apk add --update ansible git openssh-client
RUN adduser -D -u 1000 jenkins
