FROM ubuntu:latest

# Install dependencies
RUN apt-get update -y &&\
  apt-get install -y \
    nodejs \
    python-bs4 \
    wget \
    unzip \
    dos2unix \
    mysql-client \
    cron \
    && apt-get clean &&\
  rm -rf /var/lib/apt/lists/*

# Set work dir
WORKDIR /app

# Copy files
COPY app .

# Expose node port
EXPOSE 80

#CMD tail -f /dev/null
# Run setup.sh, and node
CMD ./setup.sh && \
    nodejs gtfs-server.js
