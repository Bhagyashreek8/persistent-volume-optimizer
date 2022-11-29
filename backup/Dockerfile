#FROM golang:alpine
#ENV GO111MODULE=on \
#    CGO_ENABLED=0 \
#    GOOS=linux \
#    GOARCH=x86_64
#RUN apk add curl && \
#      curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl && \
#      chmod +x ./kubectl && \
#      mv ./kubectl /usr/local/bin/kubectl
#COPY ./resource-optimizer /usr/bin/
#RUN   chmod 755 /usr/bin/resource-optimizer


FROM golang:1.18-alpine
# Set necessary environmet variables needed for our image
ENV GO111MODULE=on \
    CGO_ENABLED=0 \
    GOOS=linux \
    GOARCH=amd64
RUN apk update && apk add bash curl git
RUN mkdir /app
COPY .. /app
WORKDIR /app

RUN curl -LO https://dl.k8s.io/release/v1.25.0/bin/linux/amd64/kubectl
RUN chmod u+x kubectl && mv kubectl /bin/kubectl
RUN go build --ldflags '-extldflags "-static"' -o persistent-volume-optimizer ./main.go
#ENTRYPOINT ["./persistent-volume-optimizer"]
ENTRYPOINT ["echo", "Welcome to persistent-volume-optimizer"]
