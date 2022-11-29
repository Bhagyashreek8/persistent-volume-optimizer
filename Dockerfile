FROM ubuntu:latest

#Install Cron
RUN apt-get update
RUN apt-get -y install cron

# Set necessary environmet variables needed for our image
#ENV GO111MODULE=on \
#    CGO_ENABLED=0 \
#    GOOS=linux \
#    GOARCH=amd64

RUN mkdir /app
COPY persistent-volume-optimizer /app
COPY /scripts/moveData.sh /app
WORKDIR /app

RUN chmod +x ./app/persistent-volume-optimizer ./app/moveData.sh
#RUN go build --ldflags '-extldflags "-static"' -o persistent-volume-optimizer ./main.go
ENTRYPOINT ["./app/persistent-volume-optimizer"]

# Add the cron job
RUN crontab -l | { cat; echo "*/1 * * * * bash /app/moveData.sh"; } | crontab -

# Run the command on container startup
CMD cron

