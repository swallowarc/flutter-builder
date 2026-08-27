# Build Flutter Builder Container
FROM ubuntu:24.04
WORKDIR /app

RUN apt-get update
RUN apt-get upgrade -y
RUN apt-get install -y git wget unzip make curl
RUN apt-get clean
RUN rm -rf /var/lib/apt/lists/*

# Clone the flutter repo (pinned to the stable release tag)
ARG FLUTTER_VERSION=3.47.1
RUN git clone https://github.com/flutter/flutter.git -b ${FLUTTER_VERSION} --depth 1 /usr/local/flutter

# Set flutter path
ENV PATH="/usr/local/flutter/bin:/usr/local/flutter/bin/cache/dart-sdk/bin:${PATH}"

# Run flutter doctor
RUN flutter doctor -v

# Enable flutter web
RUN flutter config --enable-web
