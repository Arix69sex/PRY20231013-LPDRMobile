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
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height / 3,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/banner.png'),
              fit: BoxFit.cover,
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
                Text(
                  'TeCheckeo',
                  style: TextStyle(
                    fontSize: 30.0, // Adjust the font size as needed
                    color: Colors.black, // Text color
                    fontWeight: FontWeight.bold, // FontWeight
                  ),
                  textAlign: TextAlign.left, // Center the text horizontally
                ),

                buildTextField("Email", emailController),

                const SizedBox(
                    height: 5.0), // Add some space between the fields

                buildTextField("Password", passwordController),

                const SizedBox(height: 16.0),

                ElevatedButton(
                  onPressed: () async {
                    var authServiceInstance = new AuthService();
                    var response = await authServiceInstance.signup(
                        emailController.text, passwordController.text);

                    final dynamic decodedResponse = json.decode(response!.body);

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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromRGBO(241, 75, 80, 1),
                    foregroundColor: Colors.white,
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                    minimumSize: Size(350, 60),
                  ),
                ),
                SizedBox(height: 8.0), // Add some space below the login button
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      child: Text(
                        "¿Ya tienes una cuenta?",
                        style: TextStyle(
                          color: Color.fromARGB(255, 66, 66, 66),
                        ),
                      ),
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LoginPage()));
                      },
                    ),
                  ],
                ) // Add some space below the login button
              ],
            ),
          ),
        )
      ],
    )));
  }
}

Widget buildTextField(String label, TextEditingController controller) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      SizedBox(height: 12.0),
      Container(
        height: 60.0,
        width: 360.0,
        child: TextFormField(
          controller: controller,
          enabled: true, // Set the TextField as disabled
          obscureText: label == "Password" ? true : false,
          decoration: InputDecoration(
            labelText: label,
            labelStyle: TextStyle(
              color:
                  Color.fromRGBO(14, 26, 48, 1), // Change label text color here
            ),
            hintStyle:
                TextStyle(color: Color(0x49454F), fontWeight: FontWeight.bold),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4.0),
              borderSide:
                  BorderSide(color: Color.fromRGBO(56, 56, 56, 1), width: 1.0),
            ),
            focusedBorder: OutlineInputBorder(
              // Set the focused border style
              borderRadius: BorderRadius.circular(4.0),
              borderSide:
                  BorderSide(color: Color.fromRGBO(14, 26, 48, 1), width: 1.0),
            ),
          ),
        ),
      ),
      SizedBox(height: 16.0),
    ],
  );
}
