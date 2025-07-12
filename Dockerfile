# Use Ubuntu 22.04 as base image
FROM ubuntu:24.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC

# Install dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    gcc \
    g++ \
    libsctp-dev \
    libsctp1 \
    lksctp-tools \
    iproute2 \
    iputils-ping \
    wget \
    tar \
    curl \
    libssl-dev \
    libncurses-dev \
    zlib1g-dev \
    libcurl4-openssl-dev \
    libexpat1-dev \
    git \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install CMake from source
RUN wget https://github.com/Kitware/CMake/releases/download/v3.28.3/cmake-3.28.3.tar.gz && \
    tar -zxvf cmake-3.28.3.tar.gz && \
    cd cmake-3.28.3 && \
    ./bootstrap && \
    make -j$(nproc) && \
    make install && \
    cd .. && \
    rm -rf cmake-3.28.3 cmake-3.28.3.tar.gz

# Create a non-root user
RUN useradd -m -s /bin/bash ueransim

# Set working directory
WORKDIR /UERANSIM

# Copy the project source code
COPY . .

# Set ownership of the files to the ueransim user
RUN chown -R ueransim:ueransim /UERANSIM

# Switch to the ueransim user
USER ueransim

# Build the project
RUN make build

USER root

# Create directories for logs and data
RUN mkdir -p /UERANSIM/logs /UERANSIM/data

# Expose ports
# Port 38412 for N2 interface (NGAP)
# Port 2152 for N3 interface (GTP-U)
# Port 4997 for CLI interface
EXPOSE 38412 2152 4997

# Set the default command to show available executables
CMD ["bash", "-c", "echo 'UERANSIM Docker Container'; echo 'Available executables:'; ls -la /UERANSIM/build/; echo ''; echo 'Configuration files:'; ls -la /UERANSIM/config/; echo ''; echo 'Use docker exec -it <container_name> bash to interact with the container'; bash"]
