apt-get update && apt-get install -y \
    build-essential \
    libboost-python-dev \
    cmake \
    pkg-config \
    curl \
    git \
    zip \
    python-dev \
    python-numpy \
    python-setuptools \
    libgtk2.0-dev \
    libavcodec-dev \
    libavformat-dev \
    libswscale-dev

apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    easy_install pip
