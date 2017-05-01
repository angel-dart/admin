import 'package:html_builder/html_builder.dart';
import 'default/default.dart';
import 'service_mapping.dart';
import 'theme.dart';

class SpectraOptions {
  String _publicPath;
  StringRenderer _renderer;
  SpectraTheme _theme;
  String _title;
  final List<ServiceMapping> serviceMappings = [];

  SpectraOptions(
      {String publicPath,
      Iterable<ServiceMapping> serviceMappings: const [],
      StringRenderer renderer,
      SpectraTheme theme,
      String title}) {
    _publicPath = publicPath?.isNotEmpty == true ? publicPath : null;
    _renderer = renderer ?? new StringRenderer();
    _theme = theme ?? new DefaultSpectraTheme();
    _title = title;
    this.serviceMappings.addAll(serviceMappings ?? []);
  }

  factory SpectraOptions._default() => new SpectraOptions();

  factory SpectraOptions.merge(SpectraOptions a, SpectraOptions b) {
    var opts = a ?? new SpectraOptions._default();
    return opts.._merge(b);
  }

  static SpectraOptions parse(Map map) {
    if (map?.isNotEmpty != true)
      return new SpectraOptions._default();
    else {
      var opts = new SpectraOptions._default();

      if (map.containsKey('public_path')) {
        opts._publicPath = map['public_path'].toString();
      }

      if (map.containsKey('title')) {
        opts._title = map['title'].toString();
      }

      if (map['renderer'] is Map) {
        var renderer = map['renderer'] as Map;
        opts._renderer = new StringRenderer(
            html5: renderer['html5'] != false,
            pretty: renderer['pretty'] == true,
            doctype: renderer['doctype']?.toString() ?? 'html',
            whitespace: renderer['whitespace']?.toString() ?? '  ');
      }

      if (map['service_mappings'] is Iterable) {
        opts.serviceMappings
            .addAll(map['service_mappings'].map(ServiceMapping.parse));
      }

      return opts;
    }
  }

  String get publicPath => _publicPath ?? '/';

  StringRenderer get renderer => _renderer;

  SpectraTheme get theme => _theme;

  String get title => _title;

  void _merge(SpectraOptions other) {
    if (other != null) {
      serviceMappings.addAll(other.serviceMappings ?? []);

      if (other._publicPath?.isNotEmpty == true) {
        _publicPath = other._publicPath;
      }

      if (other.renderer != null) {
        _renderer = other.renderer;
      }

      if (other.theme != null) {
        _theme = other.theme;
      } else if (_theme == null) {
        _theme = new DefaultSpectraTheme();
      }

      if (other._title?.isNotEmpty == true) {
        _title = other._title;
      } else if (_title?.isNotEmpty != true) {
        _title = 'Spectra Admin';
      }
    }
  }
}
