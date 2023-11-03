package main

import (
	"fmt"
	"log"
	"net"
	"net/http"
	"os"

	"github.com/davewalker-wk/grpc-envoy-helm/gen/greeter"
	"github.com/davewalker-wk/grpc-envoy-helm/service"
	"google.golang.org/grpc"
	"google.golang.org/grpc/credentials/insecure"
	"google.golang.org/grpc/grpclog"
)

func main() {
	log := log.New(os.Stdout, "grpc", log.Ltime)
	grpclog.SetLogger(log)

	server := grpc.NewServer(grpc.Creds(insecure.NewCredentials()))
	greeter.RegisterGreeterServer(server, service.GreeterService{})

	// gRPC Server
	listener, err := net.Listen("tcp", ":8080")
	if err != nil {
		fmt.Println(err)
		return
	}

	go func() {
		fmt.Println("Starting grpc server on 8080")
		if err := server.Serve(listener); err != nil {
			fmt.Println(err)
			return
		}
	}()

	// HealthCheck
	http.DefaultServeMux.Handle("/", http.HandlerFunc(func(w http.ResponseWriter, _ *http.Request) {
		_, _ = w.Write([]byte("ok"))
	}))
	fmt.Println("Starting health probe on 80")
	err = http.ListenAndServe(":80", http.DefaultServeMux)
	if err != nil {
		fmt.Println(err)
	}
}
