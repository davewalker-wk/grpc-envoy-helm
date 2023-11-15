import 'dart:async';
import 'dart:convert';
import 'dart:html';

import 'gen/greeter/service.pbgrpc.dart';
import 'package:grpc_web/app.dart';

class GreeterGrpcApp extends App {
  final GreeterClient _service;

  GreeterGrpcApp(this._service);

  @override
  Future<void> echo(String message, bool binary) async {
    final tag = binary ? "binary: " : "string: ";
    if (message.length > 20) {
      _addLeftMessage(tag + message.substring(0, 20) + "... (len: " + message.length.toString() + ")");
    } else {
      _addLeftMessage(tag + message + " (len: " + message.length.toString() + ")");
    }

    try {
      var request = HelloRequest();
      if (binary) {
        request.data = utf8.encode(message);
      } else {
        request.name = message;
      }

      final response = await _service.sayHello(request);

      dynamic res;
      if (binary) {
        res = utf8.decode(response.dataResponse);
      } else {
        res = response.nameResponse;
      }

      if (res.length > 20) {
        _addRightMessage(tag + res.substring(0, 20) + "... (len: " + res.length.toString() + ")");
      } else {
        _addRightMessage(tag + res + " (len: " + res.length.toString() + ")");
      }
    } catch (error) {
      _addRightMessage(error.toString());
    }
  }

  void _addLeftMessage(String message) {
    _addMessage(message, 'label-primary pull-left');
  }

  void _addRightMessage(String message) {
    _addMessage(message, 'label-default pull-right');
  }

  void _addMessage(String message, String cssClass) {
    final classes = cssClass.split(' ');
    querySelector('#grpc-first')!.after(DivElement()
      ..classes.add('row')
      ..append(Element.tag('h2')
        ..append(SpanElement()
          ..classes.add('label')
          ..classes.addAll(classes)
          ..text = message)));
  }
}