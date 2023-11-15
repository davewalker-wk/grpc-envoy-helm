# GRPC with Envoy Proxy Example

Provided as a very basic example system to mimic what Workiva Environments are, and setup a basic example
service that has 3 methods of external interaction.  gRPC over HTTP/2; gRPC-web over HTTP/1 via envoy proxy;
REST over HTTP/1

The aim of this example is to demonstrate patterns of use of leveraging gRPC in many ways to apply into
DPC and Skaardb to do data collection as a potential in-kind replacement of Frugal

## Setup

1. Ensure you have Docker Desktop installed
2. Ensure you have Kubernetes cluster running within Docker
3. run `make setup`
   4. This should install nginx ingress, build docker images for the service & sidecar, install the service helm chart, and run a quick test to see if it works.
4. run `make serve` 
   5. This will open a dummy dart client at localhost:9000
   6. Entering a string, and pressing one of the buttons will initiate a request

## Examples
### Basic
This example aims to demonstrate the multiple methods of testing between a gRPC enabled web-client, and a gRPC service.
To that effect, the service is exposed in two ways 1) as a gRPC service, and 2) as a REST enabled gRPC frontend.
The former is the classic HTTP/2 based service, generally intended for service<->service communication.  The latter
allows HTTP/1 JSON data to be interpreted and handed off to gRPC handlers.

### gRPC-web
gRPC-web is a protocol designed to enable web-clients to communicate to gRPC services via a binary payload.  Rather than
needing to base64encode binary data between client & server.  To enable this functionality, there needs to be a middle layer
that can terminate the gRPC-web protocol, and pass along gRPC data to the underlying service/handler.  This can be accomplished
in one of two ways.

1. https://github.com/improbable-eng/grpc-web (deprecated)
2. https://www.envoyproxy.io/ (supported)

There is a golang library that will process gRPC-web requests, which essentially wraps a gRPC service and exposes the HTTP/1
handlers to interpret and process the protocol.  This library, although works, is no longer supported or maintained.

Use of envoy then is more than likely the preferred means to handle the gRPC-web protocol.  Workiva will, probably, not
have a _second_ means of ingress handlers, so we will look to deploy the proxy as a sidecar.  This example deployment does just that.
We setup the kubernetes cluster to route gRPC and REST traffic to the main service, but traffic bound for gRPC-web endpoints
is forwarded to the sidecar proxy, which terminates gRPC and then forwards a gRPC request to the service.

## Goals
The end goal of this exmaple is to apply patterns into DocPlatClient & Skaardb.  We are going to want to establish metrics
on what network delays, packing times, and payload size.  The data collection will hope to inform decisions around whether
we wish to pursue gRPC as a replacement of Frugal.
