# Build Flutter Builder Container
FROM google/dart
WORKDIR /app

RUN apt update
RUN apt upgrade -y
RUN apt install -y curl git wget unzip libgconf-2-4 gdb libstdc++6 libglu1-mesa fonts-droid-fallback lib32stdc++6 python3 make
RUN apt clean

# Clone the flutter repo
RUN git clone https://github.com/flutter/flutter.git -b stable --depth 1 /usr/local/flutter

# Set flutter path
ENV PATH="/usr/local/flutter/bin:/usr/local/flutter/bin/cache/dart-sdk/bin:${PATH}"

# Run flutter doctor
RUN flutter doctor -v

# Enable flutter web
RUN flutter upgrade
RUN flutter config --enable-web
