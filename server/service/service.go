package service

import (
	"context"
	"fmt"

	"github.com/davewalker-wk/grpc-envoy-helm/server/gen/greeter"
)

type GreeterService struct {
	greeter.UnimplementedGreeterServer
}

func (s GreeterService) SayHello(_ context.Context, req *greeter.HelloRequest) (*greeter.HelloReply, error) {
	if len(req.Name) > 0 {
		if len(req.Name) > 20 {
			fmt.Printf("responding %s... (%d)\n", req.Name[:20], len(req.Name))
		} else {
			fmt.Printf("responding %s (%d)\n", req.Name, len(req.Name))
		}
	}

	if len(req.Data) > 0 {
		if len(req.Data) > 20 {
			fmt.Printf("responding %s... (%d)\n", req.Data[:20], len(req.Data))
		} else {
			fmt.Printf("responding %s (%d)\n", req.Data, len(req.Data))
		}
	}
	return &greeter.HelloReply{
		NameResponse: req.Name,
		DataResponse: req.Data,
	}, nil
}
