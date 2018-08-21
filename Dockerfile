FROM hashicorp/packer:light
MAINTAINER Jesse DeFer <packer-ansible@dotd.com>

RUN adduser -D -u 1000 jenkins
RUN apk --no-cache add git openssh-client rsync py2-pip py-boto py2-six py2-cryptography py2-bcrypt py2-asn1crypto py2-yaml py2-jsonschema py2-pynacl py2-asn1 py2-markupsafe py2-paramiko py2-jinja2 py2-dateutil py2-docutils py2-futures py2-rsa && \
    pip install ansible jsonmerge awscli

COPY docker-entrypoint.sh /

ENTRYPOINT ["/docker-entrypoint.sh"]
