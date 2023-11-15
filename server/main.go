package main

import (
	"context"
	"fmt"
	"log"
	"net"
	"net/http"
	"os"

	"github.com/davewalker-wk/grpc-envoy-helm/server/gen/greeter"
	"github.com/davewalker-wk/grpc-envoy-helm/server/service"
	"github.com/gorilla/handlers"
	"github.com/grpc-ecosystem/grpc-gateway/v2/runtime"
	"google.golang.org/grpc"
	"google.golang.org/grpc/credentials/insecure"
	"google.golang.org/grpc/grpclog"
)

func main() {
	grpclog.SetLogger(log.New(os.Stdout, `grpc`, log.Ltime))

	go func() {
		server := grpc.NewServer(
			grpc.MaxRecvMsgSize(1024*1024*16),
			grpc.MaxSendMsgSize(1024*1024*16),
			grpc.Creds(insecure.NewCredentials()),
		)
		greeter.RegisterGreeterServer(server, service.GreeterService{})

		// gRPC Server
		listener, err := net.Listen(`tcp`, `:8080`)
		if err != nil {
			fmt.Println(err)
			return
		}
		fmt.Println(`Starting grpc server on 8080`)
		if err := server.Serve(listener); err != nil {
			fmt.Println(err)
			return
		}
	}()

	go func() {
		mux := runtime.NewServeMux()
		if err := greeter.RegisterGreeterHandlerServer(context.Background(), mux, service.GreeterService{}); err != nil {
			fmt.Println(err)
			return
		}

		// gRPC REST Server
		fmt.Println(`Starting grpc rest server on 9090`)
		if err := http.ListenAndServe(`:9090`, handlers.CORS(handlers.AllowedHeaders([]string{"content-type"}))(mux)); err != nil {
			fmt.Println(err)
			return
		}
	}()

	// HealthCheck
	http.DefaultServeMux.Handle(`/`, http.HandlerFunc(func(w http.ResponseWriter, _ *http.Request) {
		_, _ = w.Write([]byte(`ok`))
	}))
	fmt.Println(`Starting health probe on 88`)
	err := http.ListenAndServe(`:88`, http.DefaultServeMux)
	if err != nil {
		fmt.Println(err)
	}
}
