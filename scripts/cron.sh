#!/bin/bash
cron
sleep 5
crontab -l | { cat; echo "* * * * * bash /app/moveData.sh"; } | crontab -
crontab -l
/app/persistent-volume-optimizer
