#!/bin/bash
set -e

BACKUP_DIR="./backups"
DATE=$(date +%F_%H%M)
DB_CONTAINER="superset_db"
DB_NAME="superset"
DB_USER="superset"

mkdir -p "$BACKUP_DIR"

echo "Starting backup..."
docker exec -t "$DB_CONTAINER" pg_dump -U "$DB_USER" "$DB_NAME" > "$BACKUP_DIR/${DB_NAME}_$DATE.sql"
echo "Backup saved in $BACKUP_DIR/${DB_NAME}_$DATE.sql"

