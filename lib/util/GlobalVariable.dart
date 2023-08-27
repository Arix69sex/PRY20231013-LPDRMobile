import 'package:flutter_dotenv/flutter_dotenv.dart';

class GlobalVariable {
  
  static Future<void> loadVariables() async {
    await dotenv.load(fileName: ".env");
  }

  static Future<void> getVariable() async {
    await dotenv.env["API_URL"];
  }
}