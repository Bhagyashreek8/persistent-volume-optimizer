FROM ubuntu:20.04

USER root
#Install Cron
RUN apt-get update
RUN apt-get -y install cron rsyslog

RUN mkdir /app
COPY persistent-volume-optimizer /app
COPY /scripts/moveData.sh /app
COPY /scripts/cron.sh /app
COPY /scripts/stopCron.sh /app
WORKDIR /app

RUN chmod +x /app/persistent-volume-optimizer /app/moveData.sh /app/cron.sh /app/stopCron.sh

ENTRYPOINT ["/app/cron.sh"]

# Add the cron job
#CMD ["/app/cron.sh &"]



