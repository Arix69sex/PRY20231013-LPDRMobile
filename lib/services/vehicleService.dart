import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart';
import 'package:lpdr_mobile/util/HttpRequest.dart';

class VehicleService {
  // Constructor
  VehicleService();

  Future<Response?> getVehicles() async {
    var response;
    try {
      var baseurl = dotenv.env["API_URL"];
      print(baseurl);
      var httpRequest = new HttpRequest();

      response = await httpRequest.get('${baseurl}vehicles');

      return response;
    } catch (error) {
      print(error);
      return response;
    }
  }

  Future<Response?> getVehicleById(String vehicleId) async {
    var response;
    try {
      var baseurl = dotenv.env["API_URL"];
      print(baseurl);
      var httpRequest = new HttpRequest();

      response = await httpRequest.get('${baseurl}vehicles/${vehicleId}');

      return response;
    } catch (error) {
      print(error);
      return response;
    }
  }

  Future<Response?> getVehicleByUserId(String licensePlateId) async {
    var response;
    try {
      var baseurl = dotenv.env["API_URL"];
      print(baseurl);
      var httpRequest = new HttpRequest();

      response = await httpRequest.get('${baseurl}vehicles/licensePlate/${licensePlateId}');

      return response;
    } catch (error) {
      print(error);
      return response;
    }
  }

  Future<Response?> createVehicle(
      String licensePlateId,
      String brand,
      String model,
      String year) async {
    var response;
    try {
      var baseurl = dotenv.env["API_URL"];
      var httpRequest = new HttpRequest();

      var body = {
        "brand": brand,
        "model": model,
        "year": year,
        "licensePlateId": licensePlateId
      };

      response = await httpRequest.post('${baseurl}vehicles/create', body);

      return response;
    } catch (error) {
      print(error);
      return response;
    }
  }

  Future<Response?> updateVehicleById(
      String vehicleId,
      String? brand,
      String? model,
      String? year) async {
    var response;
    try {
      var baseurl = dotenv.env["API_URL"];
      var httpRequest = new HttpRequest();

      var body = {
        "brand": brand,
        "model": model,
        "year": year,
      };
      response = await httpRequest.patch(
          '${baseurl}vehicles/${vehicleId}/update', jsonEncode(body));

      return response;
    } catch (error) {
      print(error);
      return response;
    }
  }
}
