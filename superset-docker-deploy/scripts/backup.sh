#!/bin/bash

# Backup folder path
BACKUP_DIR="/backup"
DATE=$(date +"%Y%m%d_%H%M%S")
DB_NAME="superset_db"
BACKUP_FILE="$BACKUP_DIR/${DB_NAME}_backup_$DATE.sql"

# Create backup directory if it doesn’t exist
mkdir -p $BACKUP_DIR

# Run PostgreSQL dump
echo "Starting backup..."
docker exec -t superset_postgres pg_dump -U superset $DB_NAME > $BACKUP_FILE

echo "Backup completed: $BACKUP_FILE"
