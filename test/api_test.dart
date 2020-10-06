import 'package:yk/api/api.dart';
import 'package:yk/api/base_url.dart';

main() async {
  var api = API.getInstance();
  var is2 = await api.getPost(Site.yande);
  print(is2);
}
