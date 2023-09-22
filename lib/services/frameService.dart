import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart';
import 'package:lpdr_mobile/util/HttpRequest.dart';

class FrameService {
  // Constructor
  FrameService();

  // Method
  Future<Response?> sendFrames(String userId, Uint8List image, double latitude, double longitude) async {
    var response;
    try {
      var baseurl = dotenv.env["API_URL"];
      var httpRequest = new HttpRequest();

      var body = {
        "userId": userId,
        "image": image,
        "longitude": longitude,
        "latitude": latitude
        };

      response =
         await httpRequest.post(
          '${baseurl}licensePlates/detect', jsonEncode(body));

      return response;
    } catch (error) {
      print(error);
      return response;
    }
  }
}
