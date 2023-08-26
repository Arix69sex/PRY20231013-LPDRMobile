import 'package:flutter/material.dart';

class MessageSnackBar {
  static void showMessage(BuildContext context, String message) {
  // Simulate an error and show a snackbar
  showSnackbar(context, message);
}

}
void showSnackbar(BuildContext context, String errorMessage) {
  final snackBar = SnackBar(
    content: Text(errorMessage),
    duration:
        Duration(seconds: 3), // Duration for how long the snackbar is visible
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
