import 'package:http/http.dart' as http;
import 'package:lpdr_mobile/util/Jwt.dart';

class HttpRequest {
  final Map<String, String> contentTypeHeader;

  HttpRequest({Map<String, String>? contentTypeHeader})
      : contentTypeHeader = contentTypeHeader ??
            {
              "Content-Type": 'application/json',
            } {}

  Future<http.Response> post(String url, dynamic body) async {
    var jwt = await Jwt.getToken();
    if (jwt != null) {
      jwt = jwt.substring(1, jwt.length - 1);
      contentTypeHeader['Authorization'] = 'Bearer $jwt';
    }
    final response = await http.post(
      Uri.parse(url),
      headers: contentTypeHeader,
      body: body,
    );
    return response;
  }

  Future<http.Response> get(String url) async {
    var jwt = await Jwt.getToken();
    if (jwt != null) {
      jwt = jwt.substring(1, jwt.length - 1);
      contentTypeHeader['Authorization'] = 'Bearer $jwt';
    }
    final response = await http.get(
      Uri.parse(url),
      headers: contentTypeHeader,
    );
    return response;
  }

  Future<http.Response> patch(String url, dynamic body) async {
    var jwt = await Jwt.getToken();
    if (jwt != null) {
      jwt = jwt.substring(1, jwt.length - 1);
      contentTypeHeader['Authorization'] = 'Bearer $jwt';
    }

    final response = await http.patch(
      Uri.parse(url),
      headers: contentTypeHeader,
      body: body,
    );
    return response;
  }

  Future<http.Response> delete(String url) async {
    var jwt = await Jwt.getToken();
    if (jwt != null) {
      jwt = jwt.substring(1, jwt.length - 1);
      contentTypeHeader['Authorization'] = 'Bearer $jwt';
    }

    final response = await http.delete(
      Uri.parse(url),
      headers: contentTypeHeader,
    );
    return response;
  }
}
