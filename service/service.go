package service

import (
	"context"
	"fmt"

	"github.com/davewalker-wk/grpc-envoy-helm/gen/greeter"
)

type GreeterService struct {
	greeter.UnimplementedGreeterServer
}

func (s GreeterService) SayHello(ctx context.Context, req *greeter.HelloRequest) (*greeter.HelloReply, error) {
	fmt.Println("Doing greeter")
	fmt.Printf("responding %s\n", req.Name)
	return &greeter.HelloReply{
		Message: req.Name,
	}, nil
}
