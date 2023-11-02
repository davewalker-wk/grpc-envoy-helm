package main

import (
	"context"
	"crypto/tls"
	"fmt"

	"github.com/davewalker-wk/grpc-envoy-helm/gen/greeter"
	"google.golang.org/grpc"
	"google.golang.org/grpc/credentials"
)

func main() {
	conn, err := grpc.Dial("localhost:443", grpc.WithTransportCredentials(credentials.NewTLS(&tls.Config{
		InsecureSkipVerify: true,
	})))
	if err != nil {
		fmt.Println(err)
		return
	}

	client := greeter.NewGreeterClient(conn)

	resp, err := client.SayHello(context.Background(), &greeter.HelloRequest{Name: "Dave"})
	if err != nil {
		fmt.Println(err)
		return
	}

	fmt.Printf("Resp: %s\n", resp.Message)
}
