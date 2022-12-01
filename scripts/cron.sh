#!/bin/bash
cron
service rsyslog start
#crontab -l | { cat; echo "* * * * * bash /app/moveData.sh"; } | crontab -
#(crontab -l -u root; echo "* * * * * touch /bhagya.txt") | crontab -
(crontab -l -u root; echo "* * * * * /bin/bash -c /app/moveData.sh > /app/cronlog.log 2>&1") | crontab -
crontab -l
/app/persistent-volume-optimizer > /app/gocode.log 2>&1

#(crontab -l -u root; echo "* * * * * touch /bhagya.txt") | crontab -
