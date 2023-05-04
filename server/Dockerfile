FROM golang:1.19.8-alpine AS build
WORKDIR $GOPATH/src/github.com/micromata/dave/
COPY . .
RUN --mount=type=cache,target=/root/.cache/go-build \
    go build -o /go/bin/dave cmd/dave/main.go
RUN --mount=type=cache,target=/root/.cache/go-build \
    go build -o /go/bin/davecli cmd/davecli/main.go

FROM alpine:latest  
COPY --from=build /go/bin/davecli /usr/local/bin
COPY --from=build /go/bin/dave /usr/local/bin
COPY ./config/config.yaml /config.yaml
COPY ./webdav-home /home/webdav
COPY ./cert /home/cert
ENTRYPOINT ["/usr/local/bin/dave"]