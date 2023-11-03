import 'dart:async';
import 'dart:html';

import 'idl/hello.pbgrpc.dart';

class GreeterApp {
  final GreeterClient _service;

  GreeterApp(this._service);

  Future<void> echo(String message) async {
    _addLeftMessage(message);

    try {
      final response = await _service.sayHello(HelloRequest()..name = message);
      _addRightMessage(response.message);
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
    querySelector('#first')!.after(DivElement()
      ..classes.add('row')
      ..append(Element.tag('h2')
        ..append(SpanElement()
          ..classes.add('label')
          ..classes.addAll(classes)
          ..text = message)));
  }
}