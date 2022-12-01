#!/bin/bash
echo "stop cron job"
crontab -l
crontab -r
crontab -l
echo "delete text file"
rm /app/pvc-optimizer-01.txt
