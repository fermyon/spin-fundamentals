FROM mcr.microsoft.com/devcontainers/base:jammy

# provided by docker
ARG TARGETARCH

RUN apt-get update && apt-get install -y \
    nodejs                               \
    npm                                  \
    golang-go                            \
    python3-pip

# Install TinyGo
ARG TINYGO_VERSION="0.30.0"
RUN wget "https://github.com/tinygo-org/tinygo/releases/download/v${TINYGO_VERSION}/tinygo_${TINYGO_VERSION}_${TARGETARCH}.deb" && \
    dpkg -i "tinygo_${TINYGO_VERSION}_${TARGETARCH}.deb"

# Install Rust
RUN curl https://sh.rustup.rs -sSf | bash -s -- -y
ENV PATH="$PATH:/root/.cargo/bin"
RUN rustup target add wasm32-wasi

# Install Spin
ARG SPIN_VERSION="v1.5.0"
ENV PATH="$PATH:/usr/local/spin"
RUN mkdir -p /usr/local/spin && \
    cd /usr/local/spin && \
    curl -fsSL https://developer.fermyon.com/downloads/install.sh | bash -s -- -v $SPIN_VERSION && \
    spin plugins update && \
    spin plugins install check-for-update -y && \
    spin plugins install cloud -y && \
    spin plugins install js2wasm -y && \
    spin plugins install py2wasm -y && \
    spin templates install --upgrade --git https://github.com/fermyon/spin && \
    spin templates install --upgrade --git https://github.com/fermyon/spin-js-sdk && \
    spin templates install --upgrade --git https://github.com/fermyon/spin-python-sdk
