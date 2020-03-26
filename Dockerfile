# Go image for building the project
FROM golang:alpine as builder
RUN apk --no-cache add git dep ca-certificates

ENV GOBIN=$GOPATH/bin
ENV GO111MODULE="on"

RUN mkdir -p $GOPATH/src/bitbucket.org/walmartdigital/oraculo

WORKDIR $GOPATH/src/bitbucket.org/walmartdigital/oraculo

COPY go.mod .
COPY app/ app/
COPY vendor vendor/


RUN CGO_ENABLED=0 GOOS=linux go build -mod=vendor -a -installsuffix cgo -ldflags '-extldflags "-static"' -o $GOBIN/main ./app/main.go

# Runtime image with scratch container
FROM scratch
RUN mkdir /var/log/kafka_push
ARG VERSION
ENV VERSION_APP=$VERSION
ENV KAFKAPUSH_LOGS_FILE_PATH=/var/log/kafka_push/kafka_push.log

COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=builder /go/bin/ /app/

VOLUME /var/log/kafka_push/

EXPOSE 8089

ENTRYPOINT ["/app/main"]