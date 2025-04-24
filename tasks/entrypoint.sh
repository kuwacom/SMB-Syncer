#!/bin/bash
set -e

# 1. 必要パッケージをインストール
apt-get update
# DEBIAN_FRONTEND=noninteractive apt-get install -y cron cifs-utils ffmpeg smbclient
DEBIAN_FRONTEND=noninteractive apt-get install -y cron cifs-utils smbclient

# 2. cron 設定を登録
cp /opt/tasks/schedule.cron /etc/cron.d/sync-schedule
chmod 0644 /etc/cron.d/sync-schedule
crontab /etc/cron.d/sync-schedule

# 3. sync-task.sh を実行可能に
# chmod +x /opt/tasks/sync-task.sh

# 起動時に sync-task.sh を実行
bash /opt/tasks/sync-task.sh

# 4. cron を起動
echo "[$(date '+%Y-%m-%d %H:%M:%S')][INFO] Cron started"
cron

# 5. cron ログを表示
tail -f /var/log/sync-task.log
