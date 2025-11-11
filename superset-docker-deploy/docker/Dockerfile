# Custom Superset Docker Image with Trino & Oracle drivers
# Build: docker build -t vaishnavi2301/superset-custom:latest ./docker
# Push:  docker push vaishnavi2301/superset-custom:latest

# Base image - official Apache Superset
FROM apache/superset:latest

# Switch to root for installing system packages
USER root

# Install required libraries for database drivers
RUN apt-get update && apt-get install -y \
    libaio1 \
    unzip \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Copy and install Python dependencies
COPY requirements.txt /app/requirements.txt
RUN pip install --no-cache-dir -r /app/requirements.txt

# Switch back to non-root user for security
USER superset
