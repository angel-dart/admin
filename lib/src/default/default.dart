import 'dart:async';
import 'package:angel_framework/angel_framework.dart';
import 'package:html_builder/elements.dart';
import 'package:html_builder/html_builder.dart';
import 'package:path/path.dart' as p;
import '../options.dart';
import '../service_mapping.dart';
import '../theme.dart';

class DefaultSpectraTheme implements SpectraTheme {
  Node _page(SpectraOptions options,
      {String pageTitle, Iterable<Node> bodyChildren}) {
    return html(children: [
      head(children: [
        title(children: [text(pageTitle)]),
        link(
            rel: 'stylesheet',
            href:
                'https://cdnjs.cloudflare.com/ajax/libs/semantic-ui/2.2.10/semantic.min.css')
      ]),
      body(children: [
        div(className: 'ui menu', children: [
          a(href: options.publicPath, className: 'header item', children: [
            i(className: 'server icon'),
            text(options.title?.isNotEmpty == true
                ? options.title
                : 'Spectra Admin')
          ])
        ]),
        div(
            className: 'ui container',
            children: [
              h1(className: 'ui header', children: [text(pageTitle)])
            ]..addAll(bodyChildren ?? [])),
        script(
            src: 'https://code.jquery.com/jquery-3.2.1.min.js',
            type: 'text/javascript'),
        script(
            src:
                'https://cdnjs.cloudflare.com/ajax/libs/semantic-ui/2.2.10/semantic.min.js',
            type: 'text/javascript')
      ])
    ]);
  }

  String _serviceType(Service service) {
    return service is HookedService
        ? 'Hooked:(${_serviceType(service.inner)})'
        : service.runtimeType.toString();
  }

  @override
  Future<Node> renderServiceIndex(
      Map<String, Service> services, SpectraOptions options) {
    var root = _page(options,
        pageTitle: 'Services (${services.length})',
        bodyChildren: [
          ul(
              children: services.keys.map<Node>((k) {
            return li(children: [
              a(
                  href: p.join(options.publicPath, 'admin', 'service', k),
                  children: [text(k)])
            ]);
          }).toList())
        ]);
    return new Future<Node>.value(root);
  }

  @override
  Future<Node> renderService(
      ServiceMapping mapping, Service service, SpectraOptions options) {
    var rt = _serviceType(service);

    var root = _page(options,
        pageTitle: 'Service: ${mapping.servicePath}',
        bodyChildren: [
          i(children: [text('Runtime type: $rt')])
        ]);
    return new Future<Node>.value(root);
  }
}
