import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart';
import 'package:lpdr_mobile/util/HttpRequest.dart';

class LicensePlateService {
  // Constructor
  LicensePlateService();

  Future<Response?> getLicensePlates() async {
    var response;
    try {
      var baseurl = dotenv.env["API_URL"];
      print(baseurl);
      var httpRequest = new HttpRequest();

      response = await httpRequest.get('${baseurl}licensePlates');

      return response;
    } catch (error) {
      print(error);
      return response;
    }
  }

  Future<Response?> getLicensePlateById(String licensePlateId) async {
    var response;
    try {
      var baseurl = dotenv.env["API_URL"];
      print(baseurl);
      var httpRequest = new HttpRequest();

      response =
          await httpRequest.get('${baseurl}licensePlates/${licensePlateId}');

      return response;
    } catch (error) {
      print(error);
      return response;
    }
  }

  Future<Response?> getLicensePlateByUserId(String userId) async {
    var response;
    try {
      var baseurl = dotenv.env["API_URL"];
      print(baseurl);
      var httpRequest = new HttpRequest();

      response =
          await httpRequest.get('${baseurl}licensePlates/user/${userId}');

      return response;
    } catch (error) {
      print(error);
      return response;
    }
  }

  Future<Response?> createLicensePlate(int userId, String code, double latitude,
      double longitude, bool hasInfractions, bool takenActions) async {
    var response;
    try {
      var baseurl = dotenv.env["API_URL"];
      var httpRequest = new HttpRequest();

      var body = {
        "code": code,
        "latitude": latitude,
        "longitude": longitude,
        "hasInfractions": hasInfractions,
        "takenActions": takenActions,
        "userId": userId
      };

      response = await httpRequest.post('${baseurl}licensePlates/create', body);

      return response;
    } catch (error) {
      print(error);
      return response;
    }
  }

  Future<Uint8List> getImageOfLicensePlate(int licensePlateId) async {
    var response;
    try {
      var baseurl = dotenv.env["API_URL"];
      var httpRequest = new HttpRequest();
      response = await httpRequest
          .get('${baseurl}licensePlates/image/${licensePlateId}');
      return response.bodyBytes;
    } catch (error) {
      print(error);
      return response;
    }
  }

  Future<Response?> updateLicensePlateById(
      int licensePlateId,
      String code,
      double latitude,
      double longitude,
      bool hasInfractions,
      bool takenActions) async {
    var response;
    try {
      var baseurl = dotenv.env["API_URL"];
      var httpRequest = new HttpRequest();

      var body = {
        "code": code,
        "latitude": latitude,
        "longitude": longitude,
        "hasInfractions": hasInfractions,
        "takenActions": takenActions
      };
      response = await httpRequest.patch(
          '${baseurl}licensePlates/${licensePlateId}/update', jsonEncode(body));

      return response;
    } catch (error) {
      print(error);
      return response;
    }
  }
}
