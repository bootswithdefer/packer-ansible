FROM hashicorp/packer:light
MAINTAINER Jesse DeFer <packer-ansible@dotd.com>

ENV DOCKER_CHANNEL stable
ENV DOCKER_VERSION 19.03.5

RUN adduser -D -u 1000 jenkins

RUN mkdir -p /home/jenkins/.ssh && chmod 0700 /home/jenkins/.ssh && echo "github.com ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAq2A7hRGmdnm9tUDbO9IDSwBK6TbQa+PXYPCPy6rbTrTtw7PHkccKrpp0yVhp5HdEIcKr6pLlVDBfOLX9QUsyCOV0wzfjIJNlGEYsdlLJizHhbn2mUjvSAHQqZETYP81eFzLQNnPHt4EVVUh7VfDESU84KezmD5QlWpXLmvU31/yMf+Se8xhHTvKSCZIFImWwoG6mbUoWf9nzpIoaSjB+weqqUUmpaaasXVal72J+UX2B+2RPW3RcT0eOzQgqlJL3RKrTJvdsjE3JEAvGq3lGHSZXy28G3skua2SmVi/w4yCE6gbODqnTWlg7+wC604ydGXA8VJiS5ap43JXiUFFAaQ==" > /home/jenkins/.ssh/authorized_keys > /home/jenkins/.ssh/known_hosts && chmod 0600 /home/jenkins/.ssh/* && chown -R jenkins:jenkins /home/jenkins/.ssh

RUN apk --no-cache add git openssh-client rsync jq py2-pip py-boto py2-six py2-cryptography py2-bcrypt py2-asn1crypto py2-jsonschema py2-pynacl py2-asn1 py2-markupsafe py2-paramiko py2-dateutil py2-docutils py2-futures py2-rsa py2-libxml2 libxml2 libxslt && \
    apk --no-cache add gcc python2-dev musl-dev linux-headers libxml2-dev libxslt-dev && \
    pip install ansible jsonmerge awscli boto3 hvac ansible-modules-hashivault molecule python-gilt python-jenkins lxml openshift docker docker-compose mitogen yamale ansible-lint yamllint && \
    apk del gcc python2-dev musl-dev linux-headers libxml2-dev libxslt-dev

RUN set -eux; \
	\
# this "case" statement is generated via "update.sh"
	apkArch="$(apk --print-arch)"; \
	case "$apkArch" in \
		x86_64) dockerArch='x86_64' ;; \
		armhf) dockerArch='armel' ;; \
		aarch64) dockerArch='aarch64' ;; \
		ppc64le) dockerArch='ppc64le' ;; \
		s390x) dockerArch='s390x' ;; \
		*) echo >&2 "error: unsupported architecture ($apkArch)"; exit 1 ;;\
	esac; \
	\
	if ! wget -nv -O docker.tgz "https://download.docker.com/linux/static/${DOCKER_CHANNEL}/${dockerArch}/docker-${DOCKER_VERSION}.tgz"; then \
		echo >&2 "error: failed to download 'docker-${DOCKER_VERSION}' from '${DOCKER_CHANNEL}' for '${dockerArch}'"; \
		exit 1; \
	fi; \
	\
	tar --extract \
		--file docker.tgz \
		--strip-components 1 \
		--directory /usr/local/bin/ \
	; \
	rm docker.tgz; \
	\
	dockerd --version; \
        docker --version

COPY plugins /usr/share/ansible/plugins/

ENV ANSIBLE_FORCE_COLOR=True
ENV ANSIBLE_HOST_KEY_CHECKING=False
ENV ANSIBLE_PIPELINING=True
ENV AWS_DEFAULT_REGION=us-west-2

COPY docker-entrypoint.sh /

ENTRYPOINT ["/docker-entrypoint.sh"]
