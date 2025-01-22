# Stage 1: Build stage
FROM golang:1.21 AS builder

# Install dependencies
RUN apt-get update && apt-get install -y \
    nodejs npm sqlite3 && \
    npm install -g swagger-codegen-cli && \
    rm -rf /var/lib/apt/lists/*

# Set up working directory
WORKDIR /app

# Copy project files
COPY . .

# Generate Go dependencies
RUN go mod tidy

# Set up assets and views (adjust paths if necessary)
RUN mkdir -p /out/share/drasl && \
    cp -R ./assets ./view ./public /out/share/drasl

# Build the Go binary
RUN make build

# Stage 2: Final stage
FROM debian:bookworm-slim

# Install CA certificates
RUN apt-get update && apt-get install -y ca-certificates && \
    rm -rf /var/lib/apt/lists/*

# Set up working directory
WORKDIR /app

# Copy artifacts from the builder stage
COPY --from=builder /app/drasl /app

# Expose the default application port
EXPOSE 25585

# Command to run the server
CMD ["/app/drasl"]