FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    hydra \
    snmp \
    netcat-openbsd \
    curl \
    wget \
    build-essential \
    libmodbus-dev \
    autoconf \
    automake \
    libtool \
    pkg-config \
    git \
    python3 \
    python3-pip \
    perl \
    libnet-ssleay-perl \
    libwhisker2-perl \
    libcrypt-ssleay-perl \
    cmake \
    pipx \
    && rm -rf /var/lib/apt/lists/*

RUN git clone https://github.com/sullo/nikto.git /opt/nikto && \
    ln -s /opt/nikto/program/nikto.pl /usr/local/bin/nikto

RUN git clone https://github.com/epsilonrt/mbpoll.git /opt/mbpoll && \
    cd /opt/mbpoll && \
    mkdir build && \
    cd build && \
    cmake .. && \
    make && \
    cp mbpoll /usr/local/bin/ && \
    cd / && \
    rm -rf /opt/mbpoll

# Use the correct package name 'cme' instead of 'crackmapexec'
RUN pipx install cme

WORKDIR /attacks

COPY multi_attack.sh /attacks/multi_attack.sh
RUN chmod +x /attacks/multi_attack.sh

ENTRYPOINT ["/attacks/multi_attack.sh"]