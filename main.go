package main

import (
	"fmt"
	"net"
	"net/http"

	"github.com/davewalker-wk/grpc-envoy-helm/gen/greeter"
	"github.com/davewalker-wk/grpc-envoy-helm/service"
	"google.golang.org/grpc"
	"google.golang.org/grpc/credentials/insecure"
	"google.golang.org/grpc/reflection"
)

func main() {
	server := grpc.NewServer(grpc.Creds(insecure.NewCredentials()))
	greeter.RegisterGreeterServer(server, service.GreeterService{})
	reflection.Register(server)

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

	http.DefaultServeMux.Handle("/", http.HandlerFunc(func(w http.ResponseWriter, _ *http.Request) {
		_, _ = w.Write([]byte("ok"))
	}))

	fmt.Println("Starting health probe on 80")
	err = http.ListenAndServe(":80", http.DefaultServeMux)
	if err != nil {
		fmt.Println(err)
	}
}
