import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart';
import 'package:lpdr_mobile/util/HttpRequest.dart';

class OwnerService {
  // Constructor
  OwnerService();

  Future<Response?> getOwners() async {
    var response;
    try {
      var baseurl = dotenv.env["API_URL"];
      print(baseurl);
      var httpRequest = new HttpRequest();

      response = await httpRequest.get('${baseurl}owners');

      return response;
    } catch (error) {
      print(error);
      return response;
    }
  }

  Future<Response?> getOwnerById(String ownerId) async {
    var response;
    try {
      var baseurl = dotenv.env["API_URL"];
      print(baseurl);
      var httpRequest = new HttpRequest();

      response = await httpRequest.get('${baseurl}owners/${ownerId}');

      return response;
    } catch (error) {
      print(error);
      return response;
    }
  }

  Future<Response?> getOwnerByLicensePlateId(String licensePlateId) async {
    var response;
    try {
      var baseurl = dotenv.env["API_URL"];
      print(baseurl);
      var httpRequest = new HttpRequest();

      response = await httpRequest.get('${baseurl}owners/licensePlate/${licensePlateId}');

      return response;
    } catch (error) {
      print(error);
      return response;
    }
  }

  Future<Response?> createOwner(
      String licensePlateId,
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
        "phoneNumber": phoneNumber,
        "licensePlateId": licensePlateId
      };

      response = await httpRequest.post('${baseurl}owners/create', body);

      return response;
    } catch (error) {
      print(error);
      return response;
    }
  }

  Future<Response?> updateOwnerById(
      String ownerId,
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
          '${baseurl}owners/${ownerId}/update', jsonEncode(body));

      return response;
    } catch (error) {
      print(error);
      return response;
    }
  }
}
