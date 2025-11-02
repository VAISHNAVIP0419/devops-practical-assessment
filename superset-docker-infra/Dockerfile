# Dockerfile
FROM apache/superset:latest

USER root

# Install system dependencies (if needed)
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      build-essential \
      libpq-dev \
      wget unzip ca-certificates && \
    rm -rf /var/lib/apt/lists/*

# Install Python SQL drivers for Trino and Oracle (thin mode)
RUN pip install --upgrade pip setuptools wheel \
 && pip install trino sqlalchemy-trino python-oracledb

# Optional: install any extra Superset dependencies/plugins here
# e.g. pip install superset[sqlalchemy] or other connectors as needed

USER superset