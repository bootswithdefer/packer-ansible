FROM hashicorp/packer:light
MAINTAINER Jesse DeFer <packer-ansible@dotd.com>

RUN adduser -D -u 1000 jenkins
RUN apk --no-cache add git openssh-client rsync jq py2-pip py-boto py2-six py2-cryptography py2-bcrypt py2-asn1crypto py2-jsonschema py2-pynacl py2-asn1 py2-markupsafe py2-paramiko py2-dateutil py2-docutils py2-futures py2-rsa && \
    apk --no-cache add gcc python2-dev musl-dev linux-headers && \
    pip install ansible jsonmerge awscli boto3 ansible-modules-hashivault molecule && \
    apk del gcc python2-dev musl-dev linux-headers

COPY docker-entrypoint.sh /

ENTRYPOINT ["/docker-entrypoint.sh"]
