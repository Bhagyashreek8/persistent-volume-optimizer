#!/bin/bash
cron
sleep 5
crontab -l | { cat; echo "*/1 * * * * bash /app/moveData.sh"; } | crontab -
crontab -l
/app/persistent-volume-optimizer
