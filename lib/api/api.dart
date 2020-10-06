import 'package:dio/dio.dart';
import 'package:yk/model/image.dart' as i;

import 'base_url.dart';

var api = API.getInstance();

class API {
  Dio _dio;

  static API _instance;

  /// 内部构造方法，可避免外部暴露构造函数，进行实例化
  API._internal();

  /// 工厂构造方法，这里使用命名构造函数方式进行声明
  factory API.getInstance() => _getInstance();

  /// 获取单例内部方法
  static _getInstance() {
    // 只能有一个实例
    if (_instance == null) {
      _instance = API._internal();
      _instance._dio = Dio();
    }
    return _instance;
  }

  String _getURL(Site site, String uri) {
    switch (site) {
      case Site.yande:
        return yande + uri;
      case Site.konachan:
        return konachan + uri;
      default:
        return yande;
    }
  }

  Future<List<i.Image>> getPost(Site site,
      {int page = 1, int limit = 40, Set<String> tags}) async {
    var url = _getURL(site, "/post.json");
    var tagParam = "";
    if (tags != null) {
      tagParam = tags.join(" ");
    }
    var resp = await this._dio.get(url,
        queryParameters: {"page": page, "limit": limit, "tags": tagParam});
    return i.Images.fromJson(resp.data).images;
  }

  getPic(String url) async {
    Response<ResponseBody> rs = await this._dio.get<ResponseBody>(
          url,
          options: Options(
              responseType:
                  ResponseType.stream), // set responseType to `stream`
        );
    return rs.data.stream;
  }
}
