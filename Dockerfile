FROM hashicorp/packer:light as packer

FROM amazonlinux:latest
MAINTAINER Jesse DeFer <packer-ansible@dotd.com>

ENV DOCKER_CHANNEL stable
ENV DOCKER_VERSION 20.10.12

RUN amazon-linux-extras install postgresql13 -y
RUN yum install -y git openssh-clients rsync jq libxml2 libxslt libffi-devel openssl-devel make gcc python3-devel kernel-headers libxml2-devel libxslt-devel postgresql-devel zip libselinux-devel shadow-utils tar gzip

RUN /usr/sbin/adduser -u 1000 jenkins

RUN mkdir -p /home/jenkins/.ssh && chmod 0700 /home/jenkins/.ssh && echo "github.com ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAq2A7hRGmdnm9tUDbO9IDSwBK6TbQa+PXYPCPy6rbTrTtw7PHkccKrpp0yVhp5HdEIcKr6pLlVDBfOLX9QUsyCOV0wzfjIJNlGEYsdlLJizHhbn2mUjvSAHQqZETYP81eFzLQNnPHt4EVVUh7VfDESU84KezmD5QlWpXLmvU31/yMf+Se8xhHTvKSCZIFImWwoG6mbUoWf9nzpIoaSjB+weqqUUmpaaasXVal72J+UX2B+2RPW3RcT0eOzQgqlJL3RKrTJvdsjE3JEAvGq3lGHSZXy28G3skua2SmVi/w4yCE6gbODqnTWlg7+wC604ydGXA8VJiS5ap43JXiUFFAaQ==" > /home/jenkins/.ssh/authorized_keys > /home/jenkins/.ssh/known_hosts && chmod 0600 /home/jenkins/.ssh/* && chown -R jenkins:jenkins /home/jenkins/.ssh

COPY --from=packer /bin/packer /bin

RUN pip3 install ansible jsonmerge awscli boto boto3 hvac ansible-modules-hashivault molecule python-gilt python-jenkins lxml openshift docker docker-compose mitogen yamale ansible-lint yamllint kubernetes-validate psycopg2 dnspython selinux

RUN yum remove -y gcc python3-devel kernel-headers libxml2-devel libxslt-devel libffi-devel openssl-devel make

RUN set -eux; \
	\
# this "case" statement is generated via "update.sh"
	Arch="$(uname -m)"; \
	case "$Arch" in \
		x86_64) dockerArch='x86_64' ;; \
		armhf) dockerArch='armel' ;; \
		aarch64) dockerArch='aarch64' ;; \
		ppc64le) dockerArch='ppc64le' ;; \
		s390x) dockerArch='s390x' ;; \
		*) echo >&2 "error: unsupported architecture ($Arch)"; exit 1 ;;\
	esac; \
	\
	if ! curl -s -o docker.tgz "https://download.docker.com/linux/static/${DOCKER_CHANNEL}/${dockerArch}/docker-${DOCKER_VERSION}.tgz"; then \
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

RUN ansible-galaxy collection install infoblox.nios_modules -p /usr/share/ansible/collections

ENV ANSIBLE_FORCE_COLOR=True
ENV ANSIBLE_HOST_KEY_CHECKING=False
ENV ANSIBLE_PIPELINING=True
ENV ANSIBLE_FORKS=25
ENV AWS_DEFAULT_REGION=us-west-2

COPY docker-entrypoint.sh /

ENTRYPOINT ["/docker-entrypoint.sh"]
