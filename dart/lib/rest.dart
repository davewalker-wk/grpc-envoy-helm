import 'dart:async';
import 'dart:convert';
import 'dart:html';

import 'package:greeter/greeter.dart' show GreeterApi, GreeterHelloRequestBuilder;
import 'package:grpc_web/app.dart';

class GreeterRestApp extends App {
  final GreeterApi _service;

  GreeterRestApp(this._service);

  @override
  Future<void> echo(String message, bool binary) async {
    final tag = binary ? "binary: " : "string: ";
    if (message.length > 20) {
      _addLeftMessage(tag + message.substring(0, 20) + "... (len: " + message.length.toString() + ")");
    } else {
      _addLeftMessage(tag + message + " (len: " + message.length.toString() + ")");
    }

    try {
      var request = GreeterHelloRequestBuilder();
      if (binary) {
        request.data = base64Encode(utf8.encode(message));
      } else {
        request.name = message;
      }

      final response = await _service.greeterSayHello(
          body: request.build()
      );

      if (response.data != null) {
        dynamic res;
        if (binary) {
          if (response.data!.dataResponse != null) {
            res = utf8.decode(base64Decode(response.data!.dataResponse!));
          }
        } else {
          if (response.data!.nameResponse != null) {
            res = response.data!.nameResponse!;
          }
        }
        if (res.length > 20) {
          _addRightMessage(tag + res.substring(0, 20) + "... (len: " + res.length.toString() + ")");
        } else {
          _addRightMessage(tag + res + " (len: " + res.length.toString() + ")");
        }
      } else {
        _addRightMessage('<error>');
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
    querySelector('#rest-first')!.after(DivElement()
      ..classes.add('row')
      ..append(Element.tag('h2')
        ..append(SpanElement()
          ..classes.add('label')
          ..classes.addAll(classes)
          ..text = message)));
  }
}