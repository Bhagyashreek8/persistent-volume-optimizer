#!/usr/bin/env bash
cron
sleep 10
crontab -l | { cat; echo "*/1 * * * * bash /app/moveData.sh"; } | crontab -
crontab -l
