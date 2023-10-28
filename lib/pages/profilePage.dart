import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:lpdr_mobile/components/messageSnackBar.dart';
import 'package:lpdr_mobile/components/sideBar.dart';
import 'package:lpdr_mobile/components/topbar.dart';
import 'package:lpdr_mobile/services/userDataService.dart';
import 'package:lpdr_mobile/util/Jwt.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void openDrawer() {
    _scaffoldKey.currentState!.openDrawer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      bottomNavigationBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: TopBar(
          title: 'Mi perfil',
          onMenuPressed: openDrawer,
        ),
      ),
      drawer: Sidebar(),
      body: Column(
        children: <Widget>[
          Expanded(
            child: UserProfileView(), // Include the user profile view here
          ),
        ],
      ),
    );
  }
}

class UserProfileView extends StatefulWidget {
  @override
  _UserProfileViewState createState() => _UserProfileViewState();
}

class ItemModel {
  final IconData icon;
  final String text;

  ItemModel(this.icon, this.text);
}

class _UserProfileViewState extends State<UserProfileView> {
  int userDataId = 0;
  String email = 'example@email.com';
  String password = '********';
  String identification = '1234567890';
  String names = 'John';
  String lastNames = 'Doe';
  String address = '123 Main St';
  String phoneNumber = '+51 12345';

  bool isEditing = false;
  bool isOnProfilePage = true;

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController identificationController = TextEditingController();
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();

  Future<void> loadUserData() async {
    var userDataService = UserDataService();
    var token = await Jwt.getToken();
    var decodedToken = await Jwt.decodeToken(token!);
    final response =
        await userDataService.getUserDataByUserId(decodedToken!["id"]);
    final Map<String, dynamic> decodedResponse = json.decode(response!.body);
    final userData = decodedResponse["userData"];
    setState(() {
      userDataId = userData['id'];
      emailController.text = decodedToken['email'];
      passwordController.text = "******";
      identificationController.text = userData['identification'] ?? "";
      firstNameController.text = userData['names'] ?? "";
      lastNameController.text = userData['lastNames'] ?? "";
      addressController.text = userData['address'] ?? "";
      phoneNumberController.text = userData['phoneNumber'] ?? "";
    });
  }

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  final List<ItemModel> items = [
    ItemModel(Icons.star, 'Item 1'),
    ItemModel(Icons.favorite, 'Item 2'),
    ItemModel(Icons.thumb_up, 'Item 3'),
  ];

  void toggleEditing() {
    setState(() {
      isEditing = !isEditing;
    });
  }

  void togglePages() {
    setState(() {
      isOnProfilePage = !isOnProfilePage;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          !isOnProfilePage
              ? Container(
                  color: Colors.white,
                  padding: EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Text("Mi Perfil",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          )),
                      SizedBox(height: 10.0),
                      OutlinedButton(
                        onPressed: () async {},
                        child: Text('Infracciones'),
                        style: ButtonStyle(
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4.0),
                            ),
                          ),
                          side: MaterialStateProperty.all<BorderSide>(
                            BorderSide(
                              color: const Color.fromRGBO(
                                  235, 235, 235, 1), // Border color
                              width: 2.0, // Border width
                            ),
                          ),
                          foregroundColor: MaterialStateProperty.all<Color>(
                              Colors.black), // Text color
                          backgroundColor: MaterialStateProperty.all<Color>(
                              Colors.white), // Button color
                        ),
                      ),
                      OutlinedButton(
                        onPressed: () async {},
                        child: Text('Infracciones'),
                        style: ButtonStyle(
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4.0),
                            ),
                          ),
                          side: MaterialStateProperty.all<BorderSide>(
                            BorderSide(
                              color: const Color.fromRGBO(
                                  235, 235, 235, 1), // Border color
                              width: 2.0, // Border width
                            ),
                          ),
                          foregroundColor: MaterialStateProperty.all<Color>(
                              Colors.black), // Text color
                          backgroundColor: MaterialStateProperty.all<Color>(
                              Colors.white), // Button color
                        ),
                      ),
                    ],
                  ))
              : Container(
                  color: Colors.white,
                  padding: EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Container(
                        child: Row(children: [
                          IconButton(
                            icon: Icon(
                              Icons.arrow_back,
                              color: Colors.black, // Icon color
                              size: 40.0,
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                          Text("Mi información",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ))
                        ]),
                      ),
                      SizedBox(height: 10.0),
                      buildProfileField("Email", emailController),
                      buildProfileField("Contraseña", passwordController),
                      buildProfileField(
                          "Identificación", identificationController),
                      buildProfileField("Nombres", firstNameController),
                      buildProfileField("Apellidos", lastNameController),
                      buildProfileField("Dirección", addressController),
                      buildProfileField("Teléfono", phoneNumberController),
                      SizedBox(height: 20.0),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 0.0,
                        ),
                        child: isEditing
                            ? Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  ElevatedButton(
                                    onPressed: toggleEditing,
                                    child: Text('Cancelar'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.grey,
                                      foregroundColor: Colors.white,
                                      elevation: 3,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(4.0),
                                      ),
                                      minimumSize: Size(160, 60),
                                    ),
                                  ),
                                  SizedBox(width: 20.0),
                                  ElevatedButton(
                                    onPressed: () async {
                                      isEditing = false;
                                      email = emailController.text;
                                      password = passwordController.text;
                                      identification =
                                          identificationController.text;
                                      names = firstNameController.text;
                                      lastNames = lastNameController.text;
                                      address = addressController.text;
                                      phoneNumber = phoneNumberController.text;
                                      var userDataService = UserDataService();
                                      final response = await userDataService
                                          .updateUserDataById(
                                              userDataId,
                                              identification,
                                              names,
                                              lastNames,
                                              address,
                                              phoneNumber);
                                      if (response!.statusCode == 200) {
                                        MessageSnackBar.showMessage(
                                            context, "Perfil actualizado.");
                                        setState(() {
                                          isEditing = false;
                                        });
                                      } else {
                                        MessageSnackBar.showMessage(
                                            context, "Actualización falló.");
                                        setState(() {
                                          isEditing = true;
                                        });
                                      }
                                    },
                                    child: Text('Guardar'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          Color.fromRGBO(241, 75, 80, 1),
                                      foregroundColor: Colors.white,
                                      elevation: 3,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(4.0),
                                      ),
                                      minimumSize: Size(160, 60),
                                    ),
                                  ),
                                ],
                              )
                            : ElevatedButton(
                                onPressed: toggleEditing,
                                child: Text('Editar'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Color.fromRGBO(241, 75, 80, 1),
                                  foregroundColor: Colors.white,
                                  elevation: 3,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4.0),
                                  ),
                                  minimumSize: Size(350, 60),
                                ),
                              ),
                      )
                    ],
                  ),
                ),
        ],
      ),
    );
  }

  Widget buildProfileField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(height: 12.0),
        Container(
          height: 60.0,
          width: 350.0,
          child: TextFormField(
            controller: controller,
            enabled: isEditing ? true : false, // Set the TextField as disabled

            decoration: InputDecoration(
              labelText: label,
              labelStyle: TextStyle(
                color: Color.fromRGBO(
                    14, 26, 48, 1), // Change label text color here
              ),
              hintStyle: TextStyle(
                  color: Color(0x49454F), fontWeight: FontWeight.bold),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4.0),
                borderSide: BorderSide(
                    color: Color.fromRGBO(56, 56, 56, 1), width: 1.0),
              ),
              focusedBorder: OutlineInputBorder(
                // Set the focused border style
                borderRadius: BorderRadius.circular(4.0),
                borderSide: BorderSide(
                    color: Color.fromRGBO(14, 26, 48, 1), width: 1.0),
              ),
            ),
          ),
        ),
        SizedBox(height: 16.0),
      ],
    );
  }
}
