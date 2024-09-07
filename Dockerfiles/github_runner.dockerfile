FROM debian:bookworm
ARG TOKEN
ARG VERSION=2.319.1
ARG REPO=https://github.com/LesVu/custom_packages

ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
ENV DEBIAN_FRONTEND=noninteractive
# ENV RUNNER_ALLOW_RUNASROOT=1
# hadolint ignore=SC2086,DL3015,DL3008,DL3013,SC2015
RUN echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen \
  && echo "deb http://mirror.sg.gs/debian bookworm main contrib non-free non-free-firmware" >> /etc/apt/sources.list \
  && echo "deb http://mirror.sg.gs/debian-security bookworm-security main contrib non-free non-free-firmware" >> /etc/apt/sources.list \
  && echo "deb http://mirror.sg.gs/debian bookworm-updates main contrib non-free non-free-firmware" >> /etc/apt/sources.list \
  && rm /etc/apt/sources.list.d/debian.sources \
  && apt-get update \
  && apt-get install -y --no-install-recommends \
    gnupg \
    lsb-release \
    curl \
    tar \
    unzip \
    zip \
    apt-transport-https \
    ca-certificates \
    sudo \
    gpg-agent \
    software-properties-common \
    build-essential \
    zlib1g-dev \
    zstd \
    gettext \
    libcurl4-openssl-dev \
    inetutils-ping \
    jq \
    wget \
    dirmngr \
    openssh-client \
    locales \
    python3-pip \
    python3-setuptools \
    python3 \
    dumb-init \
    nodejs \
    rsync \
    libpq-dev \
    gosu \
  && apt-get install -y --no-install-recommends git liblttng-ust1 \
  && rm -rf /var/lib/apt/lists/* \
  && rm -rf /tmp/* \
  && groupadd -g 1001 runner \
  && useradd -mr -d /home/runner -u 1001 -g 1001 runner \
  && usermod -aG sudo runner \
  && echo '%sudo ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers \
  && mkdir /actions-runner \
  && chown runner:runner /actions-runner

RUN mkdir -p -m755 /etc/apt/keyrings \
  && curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc \
  && chmod a+r /etc/apt/keyrings/docker.asc \
  && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian $(. /etc/os-release && echo "$VERSION_CODENAME") stable" > /etc/apt/sources.list.d/docker.list \
  && apt-get update \
  && apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin \
  && usermod -aG docker runner \
  && rm -rf /var/lib/apt/lists/* \
  && rm -rf /tmp/*

WORKDIR /actions-runner
USER runner

RUN curl -o actions-runner-linux-arm64-${VERSION}.tar.gz -L https://github.com/actions/runner/releases/download/v${VERSION}/actions-runner-linux-arm64-${VERSION}.tar.gz \
  && tar xzf ./actions-runner-linux-arm64-${VERSION}.tar.gz \
  && sudo ./bin/installdependencies.sh \
  && ./config.sh --url ${REPO} --token ${TOKEN} \
      --name "self-runner" \
      --work "/actions-runner/" \
      --runnergroup "Default" \
      --unattended

COPY start.sh /
CMD ["/start.sh"]
