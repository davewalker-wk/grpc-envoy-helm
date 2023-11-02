FROM golang:1.20 as build

COPY ./ $GOPATH/src/github.com/davewalker-wk/grpc-envoy-helm
WORKDIR $GOPATH/src/github.com/davewalker-wk/grpc-envoy-helm

RUN go build -o server main.go

EXPOSE 8080

ENTRYPOINT ["./server"]