FROM ubuntu:latest

USER root
#Install Cron
RUN apt-get update
RUN apt-get -y install cron

RUN mkdir /app
COPY persistent-volume-optimizer /app
COPY /scripts/moveData.sh /app
COPY /scripts/cron.sh /app
WORKDIR /app

RUN chmod +x /app/persistent-volume-optimizer /app/moveData.sh /app/cron.sh
#RUN go build --ldflags '-extldflags "-static"' -o persistent-volume-optimizer ./main.go
ENTRYPOINT ["/app/cron.sh"]

# Add the cron job
#CMD ["/app/cron.sh &"]
#CMD crontab -l | { cat; echo "*/1 * * * * bash /app/moveData.sh"; } | crontab -


