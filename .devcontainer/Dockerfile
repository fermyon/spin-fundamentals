# The goal of this Dockerfile is to be architecture independent. To that end,
# it avoids downloading any platform-specific binaries, and installs the required
# tools either through Debian's package manager, or through installation scripts
# that download the appropriate binaries.

# If the examples in this repository require it, update this Dockerfile to install
# more language toolchains (such as .NET or TinyGo).

FROM ubuntu:22.04

RUN apt-get update && apt-get install -y \
    bash                                 \
    git                                  \
    curl                                 \
    nodejs                               \
    npm                                  \
    golang-go                            \
    build-essential libssl-dev pkg-config\
    glibc-source                         \
	wget                                 \
    ca-certificates

# Install Rust
RUN curl https://sh.rustup.rs -sSf | bash -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"
RUN rustup target add wasm32-wasi

# Install the gopls Go Language Server, see https://github.com/golang/tools/tree/master/gopls
RUN go install golang.org/x/tools/gopls@latest

# Install Spin and required plugins
RUN (curl -fsSL https://developer.fermyon.com/downloads/install.sh | bash && mv spin /usr/local/bin/) &&    \
    spin plugin install js2wasm -y &&                                                                       \
    spin templates install --git https://github.com/fermyon/spin --update &&                                \
    spin templates install --git https://github.com/fermyon/spin-js-sdk --update &&                         \
    spin templates install --git https://github.com/radu-matei/spin-kv-explorer --update &&                 \
    spin templates install --git https://github.com/radu-matei/spin-nextjs --update

# Install Docker 
#RUN [ -e /etc/nsswitch.conf ] && grep '^hosts: files dns' /etc/nsswitch.conf

ENV DOCKER_VERSION 24.0.5

RUN set -eux; \
	\
	UNAME_ARC="$(uname -m)"; \
	echo "$UNAME_ARC"; \
	case "$UNAME_ARC" in \
		'x86_64') \
			url='https://download.docker.com/linux/static/stable/x86_64/docker-24.0.5.tgz'; \
			;; \
		'armhf') \
			url='https://download.docker.com/linux/static/stable/armel/docker-24.0.5.tgz'; \
			;; \
		'armv7') \
			url='https://download.docker.com/linux/static/stable/armhf/docker-24.0.5.tgz'; \
			;; \
		'aarch64') \
			url='https://download.docker.com/linux/static/stable/aarch64/docker-24.0.5.tgz'; \
			;; \
		*) echo >&2 "error: unsupported 'docker.tgz' architecture ($UNAME_ARC)"; exit 1 ;; \
	esac; \
	\
	wget -O 'docker.tgz' "$url"; \
	\
	tar --extract \
		--file docker.tgz \
		--strip-components 1 \
		--directory /usr/local/bin/ \
		--no-same-owner \
		'docker/docker' \
	; \
	rm docker.tgz; \
	\
	docker --version

ENV DOCKER_BUILDX_VERSION 0.11.2
RUN set -eux; \
	\
	UNAME_ARC="$(uname -m)"; \
	case "$UNAME_ARC" in \
		'x86_64') \
			url='https://github.com/docker/buildx/releases/download/v0.11.2/buildx-v0.11.2.linux-amd64'; \
			sha256='311568ee69715abc46163fd688e56c77ab0144ff32e116d0f293bfc3470e75b7'; \
			;; \
		'armhf') \
			url='https://github.com/docker/buildx/releases/download/v0.11.2/buildx-v0.11.2.linux-arm-v6'; \
			sha256='c1bab0c7374406d5069f60b291971d71161fbd3c00e8a8fb1b68b9053eda8a4e'; \
			;; \
		'armv7') \
			url='https://github.com/docker/buildx/releases/download/v0.11.2/buildx-v0.11.2.linux-arm-v7'; \
			sha256='4defdf463ca2516d3f58fef69a6f78cbbb8baf16d936cdfc54df4a4be0d48f7f'; \
			;; \
		'aarch64') \
			url='https://github.com/docker/buildx/releases/download/v0.11.2/buildx-v0.11.2.linux-arm64'; \
			sha256='565e36085a35bba5104f37365ba796c111338eea1a0902b3a7ff42e2e1248815'; \
			;; \
		'ppc64le') \
			url='https://github.com/docker/buildx/releases/download/v0.11.2/buildx-v0.11.2.linux-ppc64le'; \
			sha256='c5f5cb9957890873a537c7ff5c4eef36132339622baeabb37a4b9b7251ddf836'; \
			;; \
		'riscv64') \
			url='https://github.com/docker/buildx/releases/download/v0.11.2/buildx-v0.11.2.linux-riscv64'; \
			sha256='c0adc4b4625f7e3df7dcdec840568f918673f2ed4bcd03ca1e63ea2a5627ca35'; \
			;; \
		's390x') \
			url='https://github.com/docker/buildx/releases/download/v0.11.2/buildx-v0.11.2.linux-s390x'; \
			sha256='02916c76c3872fd0b3fa57e71403fee92b6be10f350b96a5ff99e7914dd277b8'; \
			;; \
		*) echo >&2 "warning: unsupported 'docker-buildx' architecture ($UNAME_ARC); skipping"; exit 0 ;; \
	esac; \
	\
	wget -O 'docker-buildx' "$url"; \
	echo "$sha256 *"'docker-buildx' | sha256sum -c -; \
	\
	plugin='/usr/local/libexec/docker/cli-plugins/docker-buildx'; \
	mkdir -p "$(dirname "$plugin")"; \
	mv -vT 'docker-buildx' "$plugin"; \
	chmod +x "$plugin"; \
	\
	docker buildx version

ENV DOCKER_COMPOSE_VERSION 2.20.2
RUN set -eux; \
	\
	UNAME_ARC="$(uname -m)"; \
	case "$UNAME_ARC" in \
		'x86_64') \
			url='https://github.com/docker/compose/releases/download/v2.20.2/docker-compose-linux-x86_64'; \
			sha256='b9385dabb7931636a3afc0aee94625ebff3bb29584493a87804afb6ebaf2d916'; \
			;; \
		'armhf') \
			url='https://github.com/docker/compose/releases/download/v2.20.2/docker-compose-linux-armv6'; \
			sha256='39cef332454d1c7a26e12f8d9ee297908d1da9cb71112ede1816c550766ddb8e'; \
			;; \
		'armv7') \
			url='https://github.com/docker/compose/releases/download/v2.20.2/docker-compose-linux-armv7'; \
			sha256='139275f3453761b46f0837a4e4c2a00883b778abee997e299c52e1bcf3d8fc9f'; \
			;; \
		'aarch64') \
			url='https://github.com/docker/compose/releases/download/v2.20.2/docker-compose-linux-aarch64'; \
			sha256='e63a24e57d2104a09b37ee6aa04c76f4ae85bdf7a59e1bf79adc6d5f55340a31'; \
			;; \
		'ppc64le') \
			url='https://github.com/docker/compose/releases/download/v2.20.2/docker-compose-linux-ppc64le'; \
			sha256='9c08eb875a7ffd4a832a585540a4c9c81da5dcab263ec3e704ab1d62b573636f'; \
			;; \
		'riscv64') \
			url='https://github.com/docker/compose/releases/download/v2.20.2/docker-compose-linux-riscv64'; \
			sha256='5a3bff32ecf0a5a38a83afeb3dc2effd8ca3d52eb2e07ec000334663d493055b'; \
			;; \
		's390x') \
			url='https://github.com/docker/compose/releases/download/v2.20.2/docker-compose-linux-s390x'; \
			sha256='297be6a0ece070ae95d5caf91a23b89dc1b2563e928db80eee480d7018919ee6'; \
			;; \
		*) echo >&2 "warning: unsupported 'docker-compose' architecture ($UNAME_ARC); skipping"; exit 0 ;; \
	esac; \
	\
	wget -O 'docker-compose' "$url"; \
	echo "$sha256 *"'docker-compose' | sha256sum -c -; \
	\
	plugin='/usr/local/libexec/docker/cli-plugins/docker-compose'; \
	mkdir -p "$(dirname "$plugin")"; \
	mv -vT 'docker-compose' "$plugin"; \
	chmod +x "$plugin"; \
	\
	ln -sv "$plugin" /usr/local/bin/; \
	docker-compose --version; \
	docker compose version

COPY modprobe.sh /usr/local/bin/modprobe

# https://github.com/docker/docker/blob/master/project/PACKAGERS.md#runtime-dependencies
RUN apt-get install -y \
		btrfs-progs \
		e2fsprogs \
		iptables \
		openssl \
		xfsprogs \
# pigz: https://github.com/moby/moby/pull/35697 (faster gzip implementation)
		pigz

# TODO aufs-tools

# set up subuid/subgid so that "--userns-remap=default" works out-of-the-box
RUN set -eux; \
	useradd -U -m -u 1001 dockremap

RUN set -eux; \
	\
	UNAME_ARC="$(uname -m)"; \
	case "$UNAME_ARC" in \
		'x86_64') \
			url='https://download.docker.com/linux/static/stable/x86_64/docker-24.0.5.tgz'; \
			;; \
		'armhf') \
			url='https://download.docker.com/linux/static/stable/armel/docker-24.0.5.tgz'; \
			;; \
		'armv7') \
			url='https://download.docker.com/linux/static/stable/armhf/docker-24.0.5.tgz'; \
			;; \
		'aarch64') \
			url='https://download.docker.com/linux/static/stable/aarch64/docker-24.0.5.tgz'; \
			;; \
		*) echo >&2 "error: unsupported 'docker.tgz' architecture ($UNAME_ARC)"; exit 1 ;; \
	esac; \
	\
	wget -O 'docker.tgz' "$url"; \
	\
	tar --extract \
		--file docker.tgz \
		--strip-components 1 \
		--directory /usr/local/bin/ \
		--no-same-owner \
# we exclude the CLI binary because we already extracted that over in the "docker:24-cli" image that we're FROM and we don't want to duplicate those bytes again in this layer
		--exclude 'docker/docker' \
	; \
	rm docker.tgz; \
	\
	dockerd --version; \
	containerd --version; \
	ctr --version; \
	runc --version

# https://github.com/docker/docker/tree/master/hack/dind
ENV DIND_COMMIT d58df1fc6c866447ce2cd129af10e5b507705624

RUN set -eux; \
	wget -O /usr/local/bin/dind "https://raw.githubusercontent.com/docker/docker/${DIND_COMMIT}/hack/dind"; \
	chmod +x /usr/local/bin/dind

VOLUME /var/lib/docker
EXPOSE 2375 2376


# https://github.com/docker-library/docker/pull/166
#   dockerd-entrypoint.sh uses DOCKER_TLS_CERTDIR for auto-generating TLS certificates
#   docker-entrypoint.sh uses DOCKER_TLS_CERTDIR for auto-setting DOCKER_TLS_VERIFY and DOCKER_CERT_PATH
# (For this to work, at least the "client" subdirectory of this path needs to be shared between the client and server containers via a volume, "docker cp", or other means of data sharing.)
ENV DOCKER_TLS_CERTDIR=/certs
# also, ensure the directory pre-exists and has wide enough permissions for "dockerd-entrypoint.sh" to create subdirectories, even when run in "rootless" mode
RUN mkdir /certs /certs/client && chmod 1777 /certs /certs/client
# (doing both /certs and /certs/client so that if Docker does a "copy-up" into a volume defined on /certs/client, it will "do the right thing" by default in a way that still works for rootless users)


RUN apt-get install -y iproute2 fuse-overlayfs

# "/run/user/UID" will be used by default as the value of XDG_RUNTIME_DIR
RUN mkdir -p /run/user && chmod 1777 /run/user

# create a default user preconfigured for running rootless dockerd
RUN set -eux; \
	useradd -U -m -u 1000 rootless

RUN set -eux; \
	\
	UNAME_ARC="$(uname -m)"; \
	case "$UNAME_ARC" in \
		'x86_64') \
			url='https://download.docker.com/linux/static/stable/x86_64/docker-rootless-extras-24.0.5.tgz'; \
			;; \
		'aarch64') \
			url='https://download.docker.com/linux/static/stable/aarch64/docker-rootless-extras-24.0.5.tgz'; \
			;; \
		*) echo >&2 "error: unsupported 'rootless.tgz' architecture ($UNAME_ARC)"; exit 1 ;; \
	esac; \
	\
	wget -O 'rootless.tgz' "$url"; \
	\
	tar --extract \
		--file rootless.tgz \
		--strip-components 1 \
		--directory /usr/local/bin/ \
		'docker-rootless-extras/rootlesskit' \
		'docker-rootless-extras/rootlesskit-docker-proxy' \
		'docker-rootless-extras/vpnkit' \
	; \
	rm rootless.tgz; \
	\
	rootlesskit --version; \
	vpnkit --version

# pre-create "/var/lib/docker" for our rootless user
RUN set -eux; \
	mkdir -p /home/rootless/.local/share/docker; \
	chown -R rootless:rootless /home/rootless/.local/share/docker
VOLUME /home/rootless/.local/share/docker
USER rootless
