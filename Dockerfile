FROM hashicorp/packer:light
MAINTAINER Jesse DeFer <packer-ansible@dotd.com>

RUN apk --no-cache add ansible git openssh-client
RUN adduser -D -u 1000 jenkins

RUN apk --no-cache add --virtual build-dependencies python-dev py-pip build-base
RUN pip install awscli
RUN apk del build-dependencies

