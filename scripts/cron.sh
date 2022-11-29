#!/usr/bin/env bash
/app/persistent-volume-optimizer &
cron
sleep 10
crontab -l | { cat; echo "*/1 * * * * bash /app/moveData.sh"; } | crontab -
crontab -l
