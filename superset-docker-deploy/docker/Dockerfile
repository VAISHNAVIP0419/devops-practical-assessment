# Use the latest Apache Superset image as base
FROM apache/superset:latest

# Switch to root user to install dependencies
USER root

# Install required system packages
RUN apt-get update && apt-get install -y \
    libaio1 \
    unzip \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Install Python packages (Trino + Oracle drivers)
COPY requirements.txt /app/requirements.txt
RUN pip install --no-cache-dir -r /app/requirements.txt

# Switch back to Superset user
USER superset
