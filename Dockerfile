# ==============================================================================
# XM AI Scalping Bot - Containerized Headless Trading Environment
# Ubuntu 22.04 LTS + Wine 64-bit + Xvfb + Python 3.10 + MetaTrader 5
# ==============================================================================

FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive \
    WINEDEBUG=-all \
    WINEARCH=win64 \
    DISPLAY=:99 \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8

# Install base dependencies, WineHQ, Xvfb virtual frame buffer, and Python
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    wget \
    gnupg2 \
    software-properties-common \
    locales \
    xvfb \
    x11vnc \
    python3 \
    python3-pip \
    python3-venv \
    procps \
    git \
    && locale-gen en_US.UTF-8 \
    && dpkg --add-architecture i386 \
    && mkdir -pm755 /etc/apt/keyrings \
    && wget -O /etc/apt/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key \
    && wget -NP /etc/apt/sources.list.d/ https://dl.winehq.org/wine-builds/ubuntu/dists/jammy/winehq-jammy.sources \
    && apt-get update \
    && apt-get install -y --install-recommends winehq-stable \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Set up working directory
WORKDIR /app

# Copy dependency specifications and install Python packages
COPY requirements.txt .
RUN pip3 install --no-cache-dir -r requirements.txt

# Copy bot source code and scripts
COPY . .

# Grant execute permissions to helper scripts
RUN chmod +x *.sh

# Expose VNC port for remote visual inspection
EXPOSE 5900

# Entrypoint script: Launch virtual display and MT5
CMD ["bash", "-c", "Xvfb :99 -screen 0 1920x1080x24 & sleep 2 && make run && tail -f /dev/null"]

