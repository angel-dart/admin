library blog.services;

import 'package:angel_common/angel_common.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'post.dart' as post;
import 'user.dart' as user;

configureServer(Angel app) async {
  Db db = app.container.make(Db);
  await app.configure(post.configureServer(db));
  await app.configure(user.configureServer(db));
}
