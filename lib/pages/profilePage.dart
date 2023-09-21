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
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: TopBar(
          title: 'Profile',
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

  void toggleEditing() {
    setState(() {
      isEditing = !isEditing;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          Container(
            color: Colors.lightBlue,
            padding: EdgeInsets.all(20.0),
            width: double.infinity,
            height: 150.0,
            child: Center(
              child: Text(
                'Your Profile',
                style: TextStyle(
                  fontSize: 40.0,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Container(
            color: Colors.white,
            padding: EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                buildProfileField("Email", emailController),
                buildProfileField("Password", passwordController),
                buildProfileField("Identification", identificationController),
                buildProfileField("First Name", firstNameController),
                buildProfileField("Last Name", lastNameController),
                buildProfileField("Address", addressController),
                buildProfileField("Phone Number", phoneNumberController),
                SizedBox(height: 20.0),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40.0,
                  ),
                  child: isEditing
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                              onPressed: toggleEditing,
                              child: Text('Cancel'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey,
                                foregroundColor: Colors.white,
                                elevation: 3,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(32.0),
                                ),
                                minimumSize: Size(100, 40),
                              ),
                            ),
                            SizedBox(width: 20.0),
                            ElevatedButton(
                              onPressed: () async {
                                isEditing = false;
                                email = emailController.text;
                                password = passwordController.text;
                                identification = identificationController.text;
                                names = firstNameController.text;
                                lastNames = lastNameController.text;
                                address = addressController.text;
                                phoneNumber = phoneNumberController.text;
                                var userDataService = UserDataService();
                                final response =
                                    await userDataService.updateUserDataById(
                                        userDataId,
                                        identification,
                                        names,
                                        lastNames,
                                        address,
                                        phoneNumber);
                                if (response!.statusCode == 200) {
                                  MessageSnackBar.showMessage(
                                      context, "Profile updated.");
                                  setState(() {
                                    isEditing = false;
                                  });
                                } else {
                                  MessageSnackBar.showMessage(
                                      context, "Update failed.");
                                  setState(() {
                                    isEditing = false;
                                  });
                                }
                              },
                              child: Text('Save'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.lightBlue,
                                foregroundColor: Colors.white,
                                elevation: 3,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(32.0),
                                ),
                                minimumSize: Size(100, 40),
                              ),
                            ),
                          ],
                        )
                      : ElevatedButton(
                          onPressed: toggleEditing,
                          child: Text('Edit'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.lightBlue,
                            foregroundColor: Colors.white,
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(32.0),
                            ),
                            minimumSize: Size(100, 40),
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
        Text(
          label,
          style:
              TextStyle(fontSize: 15.0, color: Color.fromARGB(201, 77, 77, 77)),
        ),
        SizedBox(height: 12.0),
        Container(
          height: 50.0,
          width: 350.0,
          child: TextField(
            controller: controller,
            enabled: isEditing ? true : false, // Set the TextField as disabled
            decoration: InputDecoration(
              fillColor: Colors.grey[200],
              hintStyle: TextStyle(color: const Color.fromARGB(46, 46, 46, 1)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: BorderSide(
                    color: const Color.fromARGB(255, 51, 51, 51), width: 1.0),
              ),
              focusedBorder: OutlineInputBorder(
                // Set the focused border style
                borderRadius: BorderRadius.circular(10.0),
                borderSide: BorderSide(color: Colors.blue, width: 1.0),
              ),
            ),
          ),
        ),
        SizedBox(height: 16.0),
      ],
    );
  }
}
