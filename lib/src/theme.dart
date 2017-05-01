import 'dart:async';
import 'package:angel_framework/angel_framework.dart';
import 'package:html_builder/html_builder.dart';
import 'options.dart';
import 'service_mapping.dart';

abstract class SpectraTheme {
  Future<Node> renderServiceIndex(Map<String, Service> services, SpectraOptions options);
  Future<Node> renderService(ServiceMapping mapping, Service service, SpectraOptions options);
}
