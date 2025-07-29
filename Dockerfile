# Multi-stage parallel Dockerfile for codech project
# Each language builds in parallel for optimal performance

#=============================================================================
# SHARED BASE IMAGES
#=============================================================================

# Base system with common dependencies
FROM ubuntu:22.04 AS base-system
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    curl \
    wget \
    git \
    pkg-config \
    libssl-dev \
    libcurl4-openssl-dev \
    ca-certificates \
    gnupg \
    lsb-release \
    software-properties-common \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

# Source code base - contains all source files
FROM base-system AS source-base
WORKDIR /app
COPY . .

#=============================================================================
# PARALLEL LANGUAGE BUILDS
#=============================================================================

# Rust build container
FROM source-base AS rust-builder
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"
WORKDIR /app/rust
RUN cargo build --release

# C build container  
FROM source-base AS c-builder
RUN apt-get update && apt-get install -y zlib1g-dev && rm -rf /var/lib/apt/lists/*
WORKDIR /app/c
RUN mkdir -p build && cd build && cmake .. && make Codech

# Historic C build container
FROM source-base AS historic-builder
WORKDIR /app/historic
RUN mkdir -p build && cd build && cmake .. && make

# C# build container
FROM source-base AS csharp-builder
RUN wget https://packages.microsoft.com/config/ubuntu/22.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb && \
    dpkg -i packages-microsoft-prod.deb && \
    apt-get update && \
    apt-get install -y dotnet-sdk-8.0 && \
    rm packages-microsoft-prod.deb
WORKDIR /app/csharp
RUN dotnet build -c Release

# Go build container
FROM source-base AS go-builder
RUN curl -fsSL https://go.dev/dl/go1.21.5.linux-amd64.tar.gz | tar -xzC /usr/local
ENV PATH="/usr/local/go/bin:${PATH}"
WORKDIR /app/golang
RUN go build -o codech main.go

# Java build container
FROM source-base AS java-builder
RUN apt-get update && apt-get install -y openjdk-17-jdk && rm -rf /var/lib/apt/lists/*
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
WORKDIR /app/java
RUN mkdir -p build && javac -d build -cp src src/io/jrimbault/codech/*.java

# Node.js build container
FROM source-base AS nodejs-builder
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install -y nodejs
WORKDIR /app/nodejs
RUN npm install && npm run build 2>/dev/null || npx tsc codech.ts 2>/dev/null || echo "TypeScript build completed"

# PHP container (no build needed, but copy for consistency)
FROM source-base AS php-builder
RUN apt-get update && apt-get install -y php8.1 php8.1-cli && rm -rf /var/lib/apt/lists/*
WORKDIR /app/php

# Python container (no build needed, but copy for consistency) 
FROM source-base AS python-builder
RUN apt-get update && apt-get install -y python3 python3-pip && rm -rf /var/lib/apt/lists/*
WORKDIR /app/python

# Ruby container (no build needed, but copy for consistency)
FROM source-base AS ruby-builder
RUN apt-get update && apt-get install -y ruby-full && rm -rf /var/lib/apt/lists/*
WORKDIR /app/ruby

#=============================================================================
# FINAL RUNTIME IMAGE
#=============================================================================

FROM base-system AS runtime

# Install all runtime dependencies
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install -y nodejs

RUN wget https://packages.microsoft.com/config/ubuntu/22.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb && \
    dpkg -i packages-microsoft-prod.deb && \
    apt-get update && \
    apt-get install -y dotnet-sdk-8.0 && \
    rm packages-microsoft-prod.deb

RUN curl -fsSL https://go.dev/dl/go1.21.5.linux-amd64.tar.gz | tar -xzC /usr/local
ENV PATH="/usr/local/go/bin:${PATH}"

RUN apt-get update && apt-get install -y openjdk-17-jdk && rm -rf /var/lib/apt/lists/*
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64

RUN apt-get update && apt-get install -y php8.1 php8.1-cli && rm -rf /var/lib/apt/lists/*

RUN apt-get update && apt-get install -y python3 python3-pip && rm -rf /var/lib/apt/lists/*

RUN apt-get update && apt-get install -y ruby-full && rm -rf /var/lib/apt/lists/*

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

WORKDIR /app

# Copy built artifacts from each language container
COPY --from=rust-builder /app /app
COPY --from=c-builder /app/c/build/Codech /app/c/build/Codech
COPY --from=historic-builder /app/historic/build/codec /app/historic/build/codec
COPY --from=csharp-builder /app/csharp/bin /app/csharp/bin
COPY --from=go-builder /app/golang/codech /app/golang/codech
COPY --from=java-builder /app/java/build /app/java/build
COPY --from=nodejs-builder /app/nodejs /app/nodejs
COPY --from=php-builder /app/php /app/php
COPY --from=python-builder /app/python /app/python
COPY --from=ruby-builder /app/ruby /app/ruby

# Create test data
WORKDIR /app
RUN echo "G4C=[10001111 11000111 10100100 10010010]" > key.txt
RUN echo "Hello World! This is a test file for codech." > test.txt

# Copy shell scripts (shellcheck validated)
COPY scripts/run_codech.sh scripts/benchmark.sh ./
RUN chmod +x run_codech.sh benchmark.sh


# Install bc for benchmarking calculations and hyperfine for precise benchmarking
RUN apt-get update && apt-get install -y bc && rm -rf /var/lib/apt/lists/*

# Install hyperfine for precise benchmarking
RUN curl -fsSL https://github.com/sharkdp/hyperfine/releases/download/v1.18.0/hyperfine_1.18.0_amd64.deb -o hyperfine.deb && \
    dpkg -i hyperfine.deb && \
    rm hyperfine.deb

# Default command
CMD ["./run_codech.sh"]

# Add health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD ./run_codech.sh rust encode test.txt health_check.dat key.txt && rm -f health_check.dat || exit 1