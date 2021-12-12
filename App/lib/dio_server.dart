import 'package:dio/dio.dart';

const _API_PREFIX = 'http://220.67.127.160:5000';
class Server {

  Future<String> getReq() async {
    Response response;
    Dio dio = new Dio();
    response = await dio.get("$_API_PREFIX/first");
    return response.toString();

  }
  Future<dynamic> postReq(String query) async {
    Response response;
    Dio dio = new Dio();
    Map<String, dynamic> data ={"text":query};
//    data.putIfAbsent("userId", () => 189);
    response = await dio.post("$_API_PREFIX/prediction", data: data);
//    print(response.toString());
    return response.toString();
  }
}

Server server  = Server();