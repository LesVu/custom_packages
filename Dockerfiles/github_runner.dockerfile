FROM debian:bookworm

ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
ENV DEBIAN_FRONTEND=noninteractive
# ENV RUNNER_ALLOW_RUNASROOT=1
# hadolint ignore=SC2086,DL3015,DL3008,DL3013,SC2015
RUN echo en_US.UTF-8 UTF-8 >> /etc/locale.gen \
  && echo deb http://mirror.sg.gs/debian bookworm main contrib non-free non-free-firmware >> /etc/apt/sources.list \
  && echo deb http://mirror.sg.gs/debian-security bookworm-security main contrib non-free non-free-firmware >> /etc/apt/sources.list \
  && echo deb http://mirror.sg.gs/debian bookworm-updates main contrib non-free non-free-firmware >> /etc/apt/sources.list \
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
  && apt-get install -y --no-install-recommends git \
  && ( [[ $(apt-cache search -n liblttng-ust0 | awk '{print $1}') == "liblttng-ust0" ]] && apt-get install -y --no-install-recommends liblttng-ust0 || : ) \
  && ( [[ $(apt-cache search -n liblttng-ust1 | awk '{print $1}') == "liblttng-ust1" ]] && apt-get install -y --no-install-recommends liblttng-ust1 || : ) \
  && rm -rf /var/lib/apt/lists/* \
  && rm -rf /tmp/* \
  && groupadd -g 121 runner \
  && useradd -mr -d /home/runner -u 1001 -g 121 runner \
  && usermod -aG sudo runner \
  && echo '%sudo ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers \
  && mkdir /actions-runner \
  && chown runner:runner /actions-runner

WORKDIR /actions-runner
USER runner

RUN curl -o actions-runner-linux-arm64-2.316.1.tar.gz -L https://github.com/actions/runner/releases/download/v2.316.1/actions-runner-linux-arm64-2.316.1.tar.gz \
  && tar xzf ./actions-runner-linux-arm64-2.316.1.tar.gz && sudo ./bin/installdependencies.sh && mkdir /actions-runner/work \
  && ./config.sh --url https://github.com/LesVu/custom_packages --token placeholder \
      --name "self-runner" \
      --work "/actions-runner/work/" \
      --labels "${_LABELS}" \
      --runnergroup "Default" \
      --unattended
CMD ["/actions-runner/run.sh"]
