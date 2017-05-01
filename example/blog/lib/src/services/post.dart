import 'package:angel_common/angel_common.dart';
import 'package:mongo_dart/mongo_dart.dart';
import '../models/post.dart';
export '../models/post.dart';

AngelConfigurer configureServer(Db db) {
  return (Angel app) async {
    app.use('/api/posts', new MongoService(db.collection('posts')));
  };
}
