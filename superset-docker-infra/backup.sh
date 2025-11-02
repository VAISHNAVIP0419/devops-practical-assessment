#!/bin/bash
# backup.sh - run on host (app EC2) or container to dump Postgres DB

BACKUP_DIR=/opt/superset_backups
TIMESTAMP=$(date +"%Y%m%d-%H%M%S")
FILENAME="superset-db-$TIMESTAMP.sql.gz"

mkdir -p "$BACKUP_DIR"
# run pg_dump via docker exec on container
docker exec superset_db pg_dump -U ${POSTGRES_USER} ${POSTGRES_DB} | gzip > "$BACKUP_DIR/$FILENAME"

# Optional: rotate backups older than 7 days
find "$BACKUP_DIR" -type f -mtime +7 -name '*.gz' -delete

# Optional: upload to S3 (if aws cli configured)
# aws s3 cp "$BACKUP_DIR/$FILENAME" s3://your-backup-bucket/superset/