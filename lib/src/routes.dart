import 'dart:async';
import 'dart:io';
import 'package:angel_framework/angel_framework.dart';
import 'package:html_builder/html_builder.dart';
import 'options.dart';

class Spectra {
  SpectraOptions _options;
  Angel _app;

  Spectra([SpectraOptions options]) {
    _options = options;
  }

  Future<bool> _finalize(Node page, ResponseContext res) async {
    res
      ..contentType = ContentType.HTML
      ..write(_options.renderer.render(page))
      ..end();
    return false;
  }

  AngelConfigurer plugin() {
    return (Angel app) {
      _app = app;
      _options = new SpectraOptions.merge(
          SpectraOptions.parse(_app.spectra), _options);

      _app = app
        ..group(_options.publicPath, (router) {
          router
            ..group('/admin', (router) {
              router.get('/services', handleServiceIndex);
              router.get('/service/:name', handleService);
            });
        });
    };
  }

  Future<bool> handleServiceIndex(ResponseContext res) async {
    var services = _options.serviceMappings.fold<Map<String, Service>>(
        {}, (out, k) => out..[k.name] = _app.service(k.servicePath));
    var page = await _options.theme.renderServiceIndex(services, _options);
    return await _finalize(page, res);
  }

  Future<bool> handleService(String name, ResponseContext res) async {
    var mapping = _options.serviceMappings
        .firstWhere((m) => m.name == name, orElse: () => null);

    if (mapping == null || !_app.services.containsKey(mapping.servicePath))
      throw new AngelHttpException.notFound(
          message: 'No service named "$name" exists.');
    else {
      var page = await _options.theme
          .renderService(mapping, _app.service(mapping.servicePath), _options);
      return await _finalize(page, res);
    }
  }
}
