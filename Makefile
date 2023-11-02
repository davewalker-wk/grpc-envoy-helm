
.PHONY: buildImage
buildImage:
	@echo "Building docker image"
	docker build -t grpc-envoy:0.1.0 .

.PHONY: nginx
nginx:
	@echo "Installing ingres-nginx"
	kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.2/deploy/static/provider/aws/deploy.yaml

.PHONY: helm
helm:
	@echo "Installing grpc-envoy"
	helm install grpc helm/grpc-envoy --values helm/grpc-envoy/values.yaml

.PHONY: setup
setup: buildImage nginx helm
	@echo "Done"


.PHONY: test
test:
	grpcurl -vv -insecure -d '{"name": "test"}' localhost:443 Greeter/SayHello
