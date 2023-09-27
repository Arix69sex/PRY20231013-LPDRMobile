import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:lpdr_mobile/components/messageSnackBar.dart';
import 'package:lpdr_mobile/pages/home.dart';
import 'package:lpdr_mobile/pages/loginPage.dart';
import 'package:lpdr_mobile/services/authService.dart';
import 'package:lpdr_mobile/util/Jwt.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({Key? key}) : super(key: key);

  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
            child: Column(
      children: <Widget>[
        // First Half (Light Blue Screen)
        Container(
          color: Colors.lightBlue,
          height: MediaQuery.of(context).size.height /
              2, // Half of the screen height
          child: Center(
            child: Container(
              width:
                  MediaQuery.of(context).size.width, // Full width of the screen
              child: Text(
                'Infraction Detection',
                style: TextStyle(
                  fontSize: 40.0, // Adjust the font size as needed
                  color: Colors.white, // Text color
                  fontWeight: FontWeight.bold, // FontWeight
                ),
                textAlign: TextAlign.center, // Center the text horizontally
              ),
            ),
          ),
        ),

        // Second Half (Signup Inputs)
        ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.0), // Adjust the radius as needed
            topRight: Radius.circular(20.0), // Adjust the radius as needed
          ),
          child: Container(
            color: Colors.white,
            height: MediaQuery.of(context).size.height /
                2, // Half of the screen height
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  controller: emailController,
                ),
                const SizedBox(
                    height: 16.0), // Add some space between the fields
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    border: OutlineInputBorder(),
                  ),
                  controller: passwordController,
                  obscureText: true, // To hide the password text
                ),
                const SizedBox(
                    height: 16.0), // Add some space between the fields
                ElevatedButton(
                  onPressed: () async {
                    var authServiceInstance = new AuthService();
                    var response = await authServiceInstance.signup(
                        emailController.text, passwordController.text);

                    final dynamic decodedResponse =
                        json.decode(response!.body);
                    
                    if (response?.statusCode != 400) {
                      await Jwt.saveToken(decodedResponse["token"]);
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => HomePage(),
                      ));
                    } else {
                      MessageSnackBar.showMessage(
                          context, "Usuario ya existe.");
                    }
                    // Navigate to the sign-up pag
                  },
                  child: Text('Crear cuenta'),
                ),
                SizedBox(height: 8.0), // Add some space below the login button
                GestureDetector(
                  child: Text(
                    'Ya tienes una cuenta?',
                    style: TextStyle(
                      color: Colors.blue,
                    ),
                  ),
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => LoginPage()));
                  },
                )
              ],
            ),
          ),
        )
      ],
    )));
  }
}
