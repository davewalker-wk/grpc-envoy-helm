import 'dart:html';

import 'package:grpc/grpc_web.dart';
import 'package:grpc/service_api.dart';

import 'package:grpc_web/app.dart';
import 'package:grpc_web/grpc.dart';
import 'package:grpc_web/rest.dart';

import 'package:grpc_web/gen/greeter/service.pbgrpc.dart';

import 'package:greeter/greeter.dart';

final bigString = "lorem ipsum" * 500000;

class GRPCInterceptor extends ClientInterceptor {
  @override
  ResponseFuture<R> interceptUnary<Q, R>(ClientMethod<Q, R> method, Q request,
      CallOptions options, ClientUnaryInvoker<Q, R> invoker) {
    final newMethod = ClientMethod<Q, R>('/grpc-web' + method.path, method.requestSerializer, method.responseDeserializer);
    return invoker(newMethod, request, options);
  }
}

void main() {
  setupGrpc();
  setupRest();
}

void setupGrpc() {
  final channel = GrpcWebClientChannel.xhr(Uri.parse('http://localhost'));
  final grpcService = GreeterClient(channel,
    interceptors: [
      GRPCInterceptor(),
    ],
  );
  final app = GreeterGrpcApp(grpcService);

  setupButtons('grpc', app);
}

void setupRest() {
  final grpcService = Greeter(basePathOverride: "http://localhost/rest").getGreeterApi();
  final app = GreeterRestApp(grpcService);

  setupButtons('rest', app);
}

void setupButtons(String button, App app) {
  final stringButton = querySelector('#send-' + button + '-string') as ButtonElement;
  final binaryButton = querySelector('#send-' + button + '-binary') as ButtonElement;

  stringButton.onClick.listen((e) async {
    doButton(app, false);
  });

  binaryButton.onClick.listen((e) async {
    doButton(app, true);
  });
}

void doButton(App app, bool binary) {
  final msg = querySelector('#msg') as TextInputElement;
  var value = msg.value!.trim();
  msg.value = '';

  if (value.isEmpty) {
    value = bigString;
  }

  if (value.indexOf(' ') > 0) {
    final countStr = value.substring(0, value.indexOf(' '));
    final count = int.tryParse(countStr);

    if (count == null) {
      app.echo(value, binary);
    }
  } else {
    app.echo(value, binary);
  }
}
