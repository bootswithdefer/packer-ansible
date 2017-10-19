FROM hashicorp/packer:light
MAINTAINER Jesse DeFer <packer-ansible@dotd.com>

RUN apk add --update ansible git openssh-client
RUN useradd -ms /bin/sh -u 1000 -U jenkins
