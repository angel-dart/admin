import 'dart:isolate';
import 'package:angel_auth/angel_auth.dart';
import 'package:angel_framework/angel_framework.dart';
import 'package:angel_jael/angel_jael.dart';
import 'package:angel_seo/angel_seo.dart';
import 'package:file/file.dart';
import 'package:html/parser.dart' as html;
import 'package:logging/logging.dart';
import 'package:meta/meta.dart';
import 'service_configuration.dart';

class Admin<User> {
  final Logger logger = new Logger('angel_admin');
  final FileSystem fileSystem;
  final AdminConfiguration<User> configuration;
  final bool cacheViews;

  Admin(
      {@required this.fileSystem,
      @required this.configuration,
      this.cacheViews: false});

  AngelConfigurer configureServer({String publicPath}) {
    return (app) async {
      var assetDirectoryUri = await Isolate.resolvePackageUri(
          Uri.parse('package:angel_admin/src/res/assets'));
      var viewsDirectoryUri = await Isolate.resolvePackageUri(
          Uri.parse('package:angel_admin/src/res/views'));

      logger.config('Assets: $assetDirectoryUri');
      logger.config('Views: $viewsDirectoryUri');

      var assetDirectory = fileSystem.directory(assetDirectoryUri);
      var viewsDirectory = fileSystem.directory(viewsDirectoryUri);
      var oldViewGenerator = app.viewGenerator;
      var tempApp = new Angel();
      await tempApp.configure(jael(viewsDirectory, cacheViews: cacheViews));
      var jaelViewGenerator = tempApp.viewGenerator;
      tempApp.close();

      app.viewGenerator = (name, [params]) async {
        if (params == null && params['angel_admin:touched'] != true) {
          return await oldViewGenerator(name, params);
        } else {
          var contents = await jaelViewGenerator(name, params);
          var doc = html.parse(contents);
          await inlineAssetsIntoDocument(doc, assetDirectory);
          return doc.outerHtml;
        }
      };

      var handlers = <dynamic>[
        requireAuth,
        (ResponseContext res) {
          return res.renderParams['angel_admin:touched'] = true;
        },
      ];

      handlers.insertAll(0, configuration.middleware ?? []);
      var middleware = waterfall(handlers);

      void configureRouter(Router router) {
        router.get('/', 'Admin!');

        router.all('*', (ResponseContext res) {
          res.renderParams.remove('angel_admin:touched');
          return true;
        });
      }

      if (publicPath == null) {
        configureRouter(app.chain(middleware));
      } else {
        app.group(publicPath, (router) {
          configureRouter(router.chain(middleware));
        });
      }
    };
  }
}

class AdminConfiguration<User> {
  final String title;
  final AngelAuth<User> auth;
  final Map<String, ServiceConfiguration> services;
  final List middleware;

  const AdminConfiguration(
      {@required this.title,
      @required this.auth,
      @required this.services,
      this.middleware});
}
