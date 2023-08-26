import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart';
import 'package:lpdr_mobile/util/HttpRequest.dart';

class AuthService {
  // Constructor
  AuthService();

  // Method
  Future<Response?> login(String email, String password) async {
    var response;
    try {
      var baseurl = dotenv.env["API_URL"];
      print(baseurl);
      var httpRequest = new HttpRequest();

      var body = {"email": email, "password": password};
      response =
          await httpRequest.post('${baseurl}users/login', jsonEncode(body));

      return response;
    } catch (error) {
      print(error);
      return response;
    }
  }

  Future<Response?> signup(String email, String password) async {
    var response;
    try {
      var baseurl = dotenv.env["API_URL"];
      var httpRequest = new HttpRequest();

      var body = {"email": email, "password": password};
      response =
          await httpRequest.post('${baseurl}users/signup', jsonEncode(body));

      return response;
    } catch (error) {
      print(error);
      return response;
    }
  }
}
