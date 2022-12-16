FROM hashicorp/packer:light

ENV DOCKER_CHANNEL stable
ENV DOCKER_VERSION 20.10.20

RUN adduser -D -u 1000 jenkins

RUN apk --no-cache add git openssh-client rsync jq py-pip py-boto py-six py-cryptography py-asn1crypto py-jsonschema py-pynacl py-asn1 py-markupsafe py-paramiko py-dateutil py-docutils py-rsa libxml2 libxslt libffi-dev openssl-dev make gcc python3-dev musl-dev linux-headers libxml2-dev libxslt-dev postgresql-dev zip libselinux-dev yaml py3-yaml mariadb mariadb-client py3-mysqlclient postgresql-client libssh libssh-dev

RUN ssh-keyscan github.com > /etc/ssh/ssh_known_hosts

RUN pip install jsonmerge python-gilt python-jenkins lxml yamale yamllint psycopg2 dnspython selinux toml
RUN pip install kubernetes kubernetes-validate
RUN pip install ansible hvac 'ansible-modules-hashivault<5' molecule mitogen ansible-lint
RUN pip install docker docker-compose
RUN pip install awscli boto boto3
RUN pip install ansible-pylibssh

RUN apk del gcc python3-dev musl-dev linux-headers libxml2-dev libxslt-dev libffi-dev openssl-dev make libssh-dev
RUN apk --no-cache upgrade

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

RUN ansible-galaxy collection install infoblox.nios_modules -p /usr/share/ansible/collections
RUN ansible-galaxy collection install community.aws -p /usr/share/ansible/collections
RUN ansible-galaxy collection install community.mysql -p /usr/share/ansible/collections
RUN ansible-galaxy collection install amazon.aws -p /usr/share/ansible/collections
RUN ansible-galaxy collection install kubernetes.core -p /usr/share/ansible/collections
RUN ansible-galaxy collection install ansible.windows -p /usr/share/ansible/collections

# Arista
RUN pip install cvprac netaddr deepmerge treelib md-toc Jinja2
RUN ansible-galaxy collection install arista.eos -p /usr/share/ansible/collections
RUN ansible-galaxy collection install arista.avd -p /usr/share/ansible/collections

ENV ANSIBLE_FORCE_COLOR=True
ENV ANSIBLE_HOST_KEY_CHECKING=False
ENV ANSIBLE_PIPELINING=True
ENV ANSIBLE_FORKS=25
ENV ANSIBLE_NETWORK_CLI_SSH_TYPE=libssh
ENV AWS_DEFAULT_REGION=us-west-2

COPY docker-entrypoint.sh /

ENTRYPOINT ["/docker-entrypoint.sh"]
