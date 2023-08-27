import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart';
import 'package:lpdr_mobile/util/HttpRequest.dart';

class UserDataService {
  // Constructor
  UserDataService();

  Future<Response?> getUsersData() async {
    var response;
    try {
      var baseurl = dotenv.env["API_URL"];
      print(baseurl);
      var httpRequest = new HttpRequest();

      response = await httpRequest.get('${baseurl}usersData');

      return response;
    } catch (error) {
      print(error);
      return response;
    }
  }

  Future<Response?> getUserDataById(String userDataId) async {
    var response;
    try {
      var baseurl = dotenv.env["API_URL"];
      print(baseurl);
      var httpRequest = new HttpRequest();

      response = await httpRequest.get('${baseurl}usersData/${userDataId}');

      return response;
    } catch (error) {
      print(error);
      return response;
    }
  }

  Future<Response?> getUserDataByUserId(String userId) async {
    var response;
    try {
      var baseurl = dotenv.env["API_URL"];
      print(baseurl);
      var httpRequest = new HttpRequest();

      response = await httpRequest.get('${baseurl}usersData/user/${userId}');

      return response;
    } catch (error) {
      print(error);
      return response;
    }
  }

  Future<Response?> createUserData(
      String userId,
      String identification,
      String names,
      String lastNames,
      String address,
      String phoneNumber) async {
    var response;
    try {
      var baseurl = dotenv.env["API_URL"];
      var httpRequest = new HttpRequest();

      var body = {
        "identification": identification,
        "names": names,
        "lastNames": lastNames,
        "address": address,
        "phoneNumber": phoneNumber
      };

      response = await httpRequest.post('${baseurl}usersData/${userId}/create', body);

      return response;
    } catch (error) {
      print(error);
      return response;
    }
  }

  Future<Response?> updateUserDataById(
      String userDataId,
      String? identification,
      String? names,
      String? lastNames,
      String? address,
      String? phoneNumber) async {
    var response;
    try {
      var baseurl = dotenv.env["API_URL"];
      var httpRequest = new HttpRequest();

      var body = {
        "identification": identification,
        "names": names,
        "lastNames": lastNames,
        "address": address,
        "phoneNumber": phoneNumber
      };
      response = await httpRequest.patch(
          '${baseurl}usersData/${userDataId}/update', jsonEncode(body));

      return response;
    } catch (error) {
      print(error);
      return response;
    }
  }
}
