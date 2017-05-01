import 'package:inflection/inflection.dart';

class ServiceMapping {
  String _name;
  final String servicePath;

  ServiceMapping(this.servicePath, {String as}) {
    if (as?.isNotEmpty == true)
      _name = as;
    else {
      var split = servicePath.split('/');

      if (split.isEmpty || split.last.isEmpty)
        throw new ArgumentError(
            'Cannot map a service with an empty path. You provided: "$servicePath"');
      else {
        _name = SINGULAR.convert(split.last);
      }
    }
  }

  static ServiceMapping parse(value) {
    if (value is Map && value.isNotEmpty) {
      var k = value.keys.first;
      return new ServiceMapping(k.toString(), as: value[k]?.toString());
    } else if (value is String) {
      return new ServiceMapping(value);
    } else
      throw new ArgumentError(
          'Cannot parse $value as service mapping. Expected a String or Map.');
  }

  String get name => _name;
}
