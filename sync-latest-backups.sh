#!/bin/bash

CURDIR=$(dirname "$0")
source ${CURDIR}/.env

if [ -z "$ZIP_PASSWORD" ]; then
  echo "ZIP_PASSWORD is empty, please set it in the .env file"
  exit 1
fi

temp_zip="temp.zip"

REPO_DIR="/home/beau/Server"
BACKUP_DIR="$REPO_DIR/config/tdarr/server/Tdarr/Backups"

pushd $BACKUP_DIR

latest_backup=$(ls -t | grep -v / | head -n 1)

zip -j -P "$ZIP_PASSWORD" "$temp_zip" "$latest_backup"

mv "$temp_zip" "$latest_backup"

all_tracked_backups=$(git ls-files "$BACKUP_DIR")
for file in $all_tracked_backups; do
  if [[ "$(basename "$file")" != "$latest_backup" ]]; then
    git rm --cached "$file"
  fi
done

git add -f "$BACKUP_DIR/$latest_backup"
popd

SONARR_BACKUP_DIR="$REPO_DIR/config/sonarr/Backups/scheduled"

pushd $SONARR_BACKUP_DIR

latest_backup=$(ls -t | grep -v / | head -n 1)

zip -j -P "$ZIP_PASSWORD" "$temp_zip" "$latest_backup"

mv "$temp_zip" "$latest_backup"

all_tracked_backups=$(git ls-files "$SONARR_BACKUP_DIR")
for file in $all_tracked_backups; do
  if [[ "$(basename "$file")" != "$latest_backup" ]]; then
    git rm --cached "$file"
  fi
done

git add -f "$SONARR_BACKUP_DIR/$latest_backup"
popd

RADARR_BACKUP_DIR="$REPO_DIR/config/radarr/Backups/scheduled"

pushd $RADARR_BACKUP_DIR

latest_backup=$(ls -t | grep -v / | head -n 1)

zip -j -P "$ZIP_PASSWORD" "$temp_zip" "$latest_backup"

mv "$temp_zip" "$latest_backup"

all_tracked_backups=$(git ls-files "$RADARR_BACKUP_DIR")
for file in $all_tracked_backups; do
  if [[ "$(basename "$file")" != "$latest_backup" ]]; then
    git rm --cached "$file"
  fi
done

git add -f "$RADARR_BACKUP_DIR/$latest_backup"
popd

pushd $REPO_DIR
git commit -m "Add latest backups"
popd
