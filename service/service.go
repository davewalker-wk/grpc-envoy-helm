package service

import (
	"context"

	"github.com/davewalker-wk/grpc-envoy-helm/gen/greeter"
)

type GreeterService struct {
	greeter.UnimplementedGreeterServer
}

func (s GreeterService) SayHello(ctx context.Context, req *greeter.HelloRequest) (*greeter.HelloReply, error) {
	return &greeter.HelloReply{
		Message: req.Name,
	}, nil
}
