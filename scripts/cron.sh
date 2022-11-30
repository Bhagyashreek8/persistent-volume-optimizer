#!/bin/bash
cron
service rsyslog start
#crontab -l | { cat; echo "* * * * * bash /app/moveData.sh"; } | crontab -
(crontab -l -u root; echo "* * * * * touch /bhagya.txt") | crontab -
(crontab -l -u root; echo "* * * * * bash /app/moveData.sh") | crontab -
crontab -l
/app/persistent-volume-optimizer

#(crontab -l -u root; echo "* * * * * touch /bhagya.txt") | crontab -
