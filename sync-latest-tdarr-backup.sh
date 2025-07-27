#!/bin/bash


CURDIR=$(dirname "$0")
source ${CURDIR}/.env

REPO_DIR="/home/beau/Server"
BACKUP_DIR="$REPO_DIR/config/tdarr/server/Tdarr/Backups"

cd "$BACKUP_DIR" || exit 1

latest_backup=$(ls -t | grep -v / | head -n 1)

temp_zip="temp.zip"

if [ -z "$ZIP_PASSWORD" ]; then
  echo "ZIP_PASSWORD is empty, please set it in the .env file"
  exit 1
fi

zip -j -P "$ZIP_PASSWORD" "$temp_zip" "$latest_backup"

mv "$temp_zip" "$latest_backup"

all_tracked_backups=$(git ls-files "$BACKUP_DIR")
for file in $all_tracked_backups; do
  if [[ "$(basename "$file")" != "$latest_backup" ]]; then
    git rm --cached "$file"
  fi
done

git add -f "$BACKUP_DIR/$latest_backup"
git commit -m "Add latest Tdarr backup: $latest_backup"
git push
