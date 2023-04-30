FROM golang:1.19.8-alpine AS build
WORKDIR $GOPATH/src/github.com/micromata/dave/
COPY . .
RUN go build -o /go/bin/dave cmd/dave/main.go
RUN go build -o /go/bin/davecli cmd/davecli/main.go

FROM alpine:latest  
RUN adduser -S dave
COPY --from=build /go/bin/davecli /usr/local/bin
COPY --from=build /go/bin/dave /usr/local/bin
COPY ./config/config.yaml /config.yaml
COPY ./webdav-home /home/webdav
COPY ./cert /home/cert
RUN chown -R dave:root /home/webdav
USER dave
ENTRYPOINT ["/usr/local/bin/dave"]