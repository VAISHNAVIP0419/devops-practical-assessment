#!/bin/bash
set -e   # Exit if any command fails

# ---------- CONFIG ----------
BACKUP_DIR="./backups"               # Backup location
DATE=$(date +%F_%H%M)                # Timestamp (YYYY-MM-DD_HHMM)
DB_CONTAINER="superset_db"           # Docker container name
DB_NAME="superset"                   # Database name
DB_USER="superset"                   # Database user

# ---------- SETUP ----------
mkdir -p "$BACKUP_DIR"               # Create dir if not exists

# ---------- BACKUP ----------
echo "Starting backup..."
docker exec -t "$DB_CONTAINER" pg_dump -U "$DB_USER" "$DB_NAME" > "$BACKUP_DIR/${DB_NAME}_$DATE.sql"

# ---------- DONE ----------
echo "Backup saved in $BACKUP_DIR/${DB_NAME}_$DATE.sql"