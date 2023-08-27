import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart';
import 'package:lpdr_mobile/util/HttpRequest.dart';

class UserService {
  // Constructor
  UserService();

  // Method
  Future<Response?> getUsers() async {
    var response;
    try {
      var baseurl = dotenv.env["API_URL"];
      print(baseurl);
      var httpRequest = new HttpRequest();

      response =
          await httpRequest.get('${baseurl}users');

      return response;
    } catch (error) {
      print(error);
      return response;
    }
  }

  Future<Response?> getUserById(String userId) async {
    var response;
    try {
      var baseurl = dotenv.env["API_URL"];
      var httpRequest = new HttpRequest();

      response =
          await httpRequest.get('${baseurl}users/${userId}');

      return response;
    } catch (error) {
      print(error);
      return response;
    }
  }

  Future<Response?> updateUserById(String userId, String email, String password) async {
    var response;
    try {
      var baseurl = dotenv.env["API_URL"];
      var httpRequest = new HttpRequest();

      var body = {"email": email, "password": password};
      response =
          await httpRequest.patch('${baseurl}users/${userId}/update', jsonEncode(body));

      return response;
    } catch (error) {
      print(error);
      return response;
    }
  }
}
