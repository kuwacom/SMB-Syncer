#!/bin/bash
set -e

SMB_MOUNT="/mnt/share"
SYNC_DIR="/mnt/sync"
mkdir -p "$SMB_MOUNT" "$SYNC_DIR"

echo "[$(date '+%Y-%m-%d %H:%M:%S')][INFO] Starting sync-task.sh"

echo "[$(date '+%Y-%m-%d %H:%M:%S')][INFO] Mounting SMB share: //$SMB_HOST/$SMB_SHARE_NAME"
mount -t cifs "//${SMB_HOST}/${SMB_SHARE_NAME}" "$SMB_MOUNT" \
    -o "username=${SMB_USER},password=${SMB_PASS},iocharset=utf8,sec=ntlmssp"

SEARCH_DIR="${SMB_MOUNT}/${TARGET_SUBDIR}"
if [ ! -d "$SEARCH_DIR" ]; then
    echo "[ERROR] SMBディレクトリが存在しません: $SEARCH_DIR"
    umount "$SMB_MOUNT"
    exit 1
fi

for pattern in $PATTERNS; do
    echo "[$(date '+%Y-%m-%d %H:%M:%S')][INFO] Searching pattern: *${pattern}*.mp4"
    # パターンごとのコピー先ディレクトリを作成
    dest_dir="${SYNC_DIR}/${pattern}"
    mkdir -p "$dest_dir"

    # CMを含んだファイルは除外(例: 2023-01-01-00-00-00-cm.mp4)
    find "$SEARCH_DIR" -type f -name "*${pattern}*.mp4" ! -name "*-cm.mp4" | while read -r src; do
        filename="$(basename "$src")"
        dest="${dest_dir}/${filename}"
        # 既に存在する場合はスキップ
        if [ -f "$dest" ]; then
            echo "[SKIP] Already exists: $filename"
        else
            echo "[COPY] $filename → $dest"
            cp "$src" "$dest"
        fi
    done
done

echo "[$(date '+%Y-%m-%d %H:%M:%S')][INFO] Unmounting SMB share"
umount "$SMB_MOUNT"
