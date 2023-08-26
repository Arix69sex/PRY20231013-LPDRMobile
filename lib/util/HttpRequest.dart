import 'package:http/http.dart' as http;

class HttpRequest {
  final Map<String, String> contentTypeHeader;

  HttpRequest({
    Map<String, String>? contentTypeHeader,
  }) : contentTypeHeader = contentTypeHeader ?? {
          "Content-Type": 'application/json',
    };

  Future<http.Response> post(String url, dynamic body) async {
    final response = await http.post(
      Uri.parse(url),
      headers: contentTypeHeader,
      body: body,
    );
    return response;
  }

  Future<http.Response> get(String url) async {
    final response = await http.get(
      Uri.parse(url),
      headers: contentTypeHeader,
    );
    return response;
  }

  Future<http.Response> patch(String url, dynamic body) async {
    final response = await http.patch(
      Uri.parse(url),
      headers: contentTypeHeader,
      body: body,
    );
    return response;
  }

  Future<http.Response> delete(String url) async {
    final response = await http.delete(
      Uri.parse(url),
      headers: contentTypeHeader,
    );
    return response;
  }
}