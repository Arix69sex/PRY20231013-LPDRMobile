import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart';
import 'package:lpdr_mobile/util/HttpRequest.dart';

class InfractionService {
  // Constructor
  InfractionService();

  Future<Response?> getInfractions() async {
    var response;
    try {
      var baseurl = dotenv.env["API_URL"];
      var httpRequest = new HttpRequest();

      response = await httpRequest.get('${baseurl}infractions');

      return response;
    } catch (error) {
      print(error);
      return response;
    }
  }

  Future<Response?> getInfractionById(String infractionId) async {
    var response;
    try {
      var baseurl = dotenv.env["API_URL"];
      var httpRequest = new HttpRequest();

      response = await httpRequest.get('${baseurl}infractions/${infractionId}');

      return response;
    } catch (error) {
      print(error);
      return response;
    }
  }

  Future<Response?> getInfractionByLicensePlateId(String licensePlateId) async {
    var response;
    try {
      var baseurl = dotenv.env["API_URL"];
      var httpRequest = new HttpRequest();

      response = await httpRequest.get('${baseurl}infractions/licensePlate/${licensePlateId}');

      return response;
    } catch (error) {
      print(error);
      return response;
    }
  }

  Future<Response?> createInfraction(
      String licensePlateId,
      String name,
      String level,
      String fine) async {
    var response;
    try {
      var baseurl = dotenv.env["API_URL"];
      var httpRequest = new HttpRequest();

      var body = {
        "name": name,
        "level": level,
        "fine": fine,
        "licensePlateId": licensePlateId
      };

      response = await httpRequest.post('${baseurl}infractions/create', body);

      return response;
    } catch (error) {
      print(error);
      return response;
    }
  }

  Future<Response?> updateInfractionById(
      String infractionId,
      String? name,
      String? level,
      String? fine) async {
    var response;
    try {
      var baseurl = dotenv.env["API_URL"];
      var httpRequest = new HttpRequest();

      var body = {
        "name": name,
        "level": level,
        "fine": fine,
      };
      response = await httpRequest.patch(
          '${baseurl}infractions/${infractionId}/update', jsonEncode(body));

      return response;
    } catch (error) {
      print(error);
      return response;
    }
  }
}
