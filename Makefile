.PHONY: kubernetesRunning
kubernetesRunning:
	@kubectl config use-context docker-desktop || echo "ERROR: Please install kubernetes in docker desktop, and ensure your kubeconfig has docker-desktop context" && exit
	@kubectl cluster-info &> /dev/null || echo "ERROR: Please install kubernetes in docker desktop" && exit


.PHONY: buildImage
buildImage:
	@echo "Building docker image"
	@docker build -f Dockerfile.service -t grpc-envoy:0.1.0 .
	@docker build -f Dockerfile.envoy -t grpc-envoy-sidecar:0.1.0 .

.PHONY: nginx
nginx:
	@echo "Installing ingres-nginx"
	@kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.2/deploy/static/provider/aws/deploy.yaml &> /dev/null
	@kubectl wait --for=condition=Ready=True pod -l app.kubernetes.io/instance=ingress-nginx,app.kubernetes.io/component=controller -n ingress-nginx || echo "ERROR: Unable to find ingress-nginx Available"
	@echo "Done installing ingres-nginx"

.PHONY: helm
helm:
	@echo "Installing grpc-envoy service"
	@helm upgrade grpc helm/grpc-envoy --values helm/grpc-envoy/values.yaml --install &> /dev/null
	@kubectl wait --for=condition=Ready=True pod -l app.kubernetes.io/instance=grpc,app.kubernetes.io/name=grpc-envoy -n default || echo "ERROR: Unable to find running grpc-envoy"
	@sleep 3
	@echo "Done installing grpc-envoy service"

.PHONY: test
test:
	@echo "Testing if the service is reachable"
	@grpcurl -proto idl/hello.proto -v -insecure -d '{"name": "it works"}' localhost:443 wdesk.grpc.greeter.Greeter/SayHello

.PHONY: setup
setup: kubernetesRunning buildImage nginx helm test
	@echo "Done"

.PHONY: serve
serve:
	webdev serve web:9000
	echo "http://localhost:9000"

