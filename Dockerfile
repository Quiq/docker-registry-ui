FROM golang:1.16.3-alpine3.13 as builder

RUN apk update && \
    apk add ca-certificates git bash gcc musl-dev

WORKDIR /opt/src
ADD events events
ADD registry registry

ADD go.mod go.sum ./
RUN go mod download

ADD *.go ./
RUN go test -v ./registry && \
    go build -o /opt/docker-registry-ui *.go


FROM alpine:3.13

WORKDIR /opt
RUN apk add --no-cache ca-certificates tzdata && \
    mkdir /opt/data && \
    chown nobody /opt/data

ADD templates /opt/templates
ADD static /opt/static
COPY --from=builder /opt/docker-registry-ui /opt/

USER nobody
ENTRYPOINT ["/opt/docker-registry-ui"]
