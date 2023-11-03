import 'dart:html';

import 'package:grpc/grpc_web.dart';
import 'package:grpc/service_api.dart';
import 'package:grpc_web/app.dart';
import 'package:grpc_web/idl/hello.pbgrpc.dart';

class GRPCInterceptor extends ClientInterceptor {
  @override
  ResponseFuture<R> interceptUnary<Q, R>(ClientMethod<Q, R> method, Q request,
      CallOptions options, ClientUnaryInvoker<Q, R> invoker) {
    final newMethod = ClientMethod<Q, R>('/grpc-web' + method.path, method.requestSerializer, method.responseDeserializer);
    return invoker(newMethod, request, options);
  }
}

void main() {
  final channel = GrpcWebClientChannel.xhr(Uri.parse('http://localhost'));
  final service = GreeterClient(channel,
    interceptors: [
      GRPCInterceptor(),
    ],
  );
  final app = GreeterApp(service);

  final button = querySelector('#send') as ButtonElement;
  button.onClick.listen((e) async {
    final msg = querySelector('#msg') as TextInputElement;
    final value = msg.value!.trim();
    msg.value = '';

    if (value.isEmpty) return;

    if (value.indexOf(' ') > 0) {
      final countStr = value.substring(0, value.indexOf(' '));
      final count = int.tryParse(countStr);

      if (count != null) {
      } else {
        app.echo(value);
      }
    } else {
      app.echo(value);
    }
  });
}