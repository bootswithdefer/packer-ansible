FROM hashicorp/packer:light
MAINTAINER Jesse DeFer <packer-ansible@dotd.com>

RUN adduser -D -u 1000 jenkins

RUN mkdir -p /home/jenkins/.ssh && chmod 0700 /home/jenkins/.ssh && echo -e "Host github.com\n\tStrictHostKeyChecking no\n" >> /home/jenkins/.ssh/config && chmod 0600 /home/jenkins/.ssh/config && chown -R jenkins:jenkins /home/jenkins/.ssh

RUN apk --no-cache add git openssh-client rsync jq py2-pip py-boto py2-six py2-cryptography py2-bcrypt py2-asn1crypto py2-jsonschema py2-pynacl py2-asn1 py2-markupsafe py2-paramiko py2-dateutil py2-docutils py2-futures py2-rsa py2-libxml2 libxml2 libxslt && \
    apk --no-cache add gcc python2-dev musl-dev linux-headers libxml2-dev libxslt-dev && \
    pip install ansible jsonmerge awscli boto3 hvac ansible-modules-hashivault molecule python-gilt python-jenkins lxml openshift docker docker-compose && \
    apk del gcc python2-dev musl-dev linux-headers libxml2-dev libxslt-dev

COPY docker-entrypoint.sh /

ENTRYPOINT ["/docker-entrypoint.sh"]
