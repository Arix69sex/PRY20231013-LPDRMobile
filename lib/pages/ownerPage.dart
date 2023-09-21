import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:lpdr_mobile/components/itemRow.dart';
import 'package:lpdr_mobile/components/sideBar.dart';
import 'package:lpdr_mobile/components/topbar.dart';
import 'package:lpdr_mobile/models/licensePlateModel.dart';
import 'package:lpdr_mobile/models/ownerModel.dart';
import 'package:lpdr_mobile/services/licensePlateService.dart';
import 'package:lpdr_mobile/services/ownerService.dart';

class OwnerPage extends StatefulWidget {
  final int licensePlateId;

  OwnerPage({required this.licensePlateId});

  @override
  _OwnerPageState createState() => _OwnerPageState();
}

class _OwnerPageState extends State<OwnerPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late final LicensePlateService licensePlateService;
  late final OwnerService ownerService;

  late LicensePlate licensePlate = LicensePlate(
      id: 0,
      longitude: 0.0,
      latitude: 0.0,
      code: '',
      imageUrl: Uint8List.fromList([65, 66, 67, 68, 69]),
      hasInfractions: false,
      takenActions: false,
      userId: 0);

  late Owner owner = Owner(
      id: 0,
      identification: "",
      names: "",
      lastNames: '',
      address: "",
      phoneNumber: "",
      licensePlateId: 0);

  @override
  void initState() {
    super.initState();
    licensePlateService = LicensePlateService();
    ownerService = OwnerService();
    getOwner(widget.licensePlateId);
  }

  void getOwner(int id) async {
    var response = await licensePlateService.getLicensePlateById(id.toString());
    final Map<String, dynamic> decodedlicensePlateResponse =
        json.decode(response!.body)["licensePlate"];

    response = await ownerService
        .getOwnerByLicensePlateId(decodedlicensePlateResponse["id"].toString());
    final Map<String, dynamic> decodedOwnerResponse =
        json.decode(response!.body)?["owner"];
    setState(() {
      licensePlate = LicensePlate(
          id: decodedlicensePlateResponse["id"],
          code: decodedlicensePlateResponse["code"],
          longitude: decodedlicensePlateResponse["longitude"],
          latitude: decodedlicensePlateResponse["latitude"],
          imageUrl: decodedlicensePlateResponse["imageData"] != ""
              ? decodedlicensePlateResponse["imageData"]
              : 'https://media.wired.com/photos/5e2b52d1097df7000896da19/16:9/w_2399,h_1349,c_limit/Transpo-licenseplates-502111737.jpg',
          hasInfractions: decodedlicensePlateResponse["hasInfractions"],
          takenActions: decodedlicensePlateResponse["takenActions"],
          userId: decodedlicensePlateResponse["user"]);

      owner = Owner(
          id: decodedOwnerResponse["id"],
          identification: decodedOwnerResponse["identification"],
          names: decodedOwnerResponse["names"],
          lastNames: decodedOwnerResponse["lastNames"],
          address: decodedOwnerResponse["address"],
          phoneNumber: decodedOwnerResponse["phoneNumber"],
          licensePlateId: decodedOwnerResponse["licensePlate"]);
    });
  }

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
          title: 'Owner',
          onMenuPressed: openDrawer,
        ),
      ),
      drawer: Sidebar(),
      body: Column(
        children: <Widget>[
          Container(
            color: Colors.lightBlue,
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.2,
            child: Center(
              child: Text(
                licensePlate.code,
                style: TextStyle(
                  fontSize: 50,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          SizedBox(height: 30), // Adjust the spacing as needed
          Text(
            'Owner',
            style: TextStyle(fontSize: 30),
          ),
          SizedBox(height: 15), // Adjust the spacing as needed
          Container(
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 241, 241, 241), // Background color
              border: Border.all(
                color: const Color.fromARGB(255, 223, 223, 223), // Border color
                width: 1.0, // Border width
              ),
              borderRadius: BorderRadius.circular(10.0), // Border radius
            ),
            margin: EdgeInsets.all(16),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(height: 15),

                  ItemRow(
                      icon: Icons.person,
                      text: "${owner.names} ${owner.lastNames}",
                      textSize: 20.0
                  ),

                  SizedBox(height: 20), // Adjust the spacing as needed

                  ItemRow(icon: Icons.badge, text: owner.identification),

                  SizedBox(height: 20),

                  ItemRow(icon: Icons.location_on, text: owner.address),

                  SizedBox(height: 15),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
