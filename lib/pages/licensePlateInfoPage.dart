import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:lpdr_mobile/components/sideBar.dart';
import 'package:lpdr_mobile/components/topbar.dart';
import 'package:lpdr_mobile/models/licensePlateModel.dart';
import 'package:lpdr_mobile/pages/infractionsPage.dart';
import 'package:lpdr_mobile/pages/ownerPage.dart';
import 'package:lpdr_mobile/services/infractionService.dart';
import 'package:lpdr_mobile/services/licensePlateService.dart';

class LicensePlateInfoPage extends StatefulWidget {
  final int id; // Add an ID field

  LicensePlateInfoPage(
      {required this.id}); // Constructor that takes an ID parameter

  @override
  _LicensePlateInfoPageState createState() => _LicensePlateInfoPageState();
}

class _LicensePlateInfoPageState extends State<LicensePlateInfoPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late final LicensePlateService licensePlateService;
  late final InfractionService infractionsService;
  late LicensePlate licensePlate = LicensePlate(
      id: 0,
      longitude: 0.0,
      latitude: 0.0,
      code: 'TEST123',
      imageUrl:
          'https://media.wired.com/photos/5e2b52d1097df7000896da19/16:9/w_2399,h_1349,c_limit/Transpo-licenseplates-502111737.jpg',
      hasInfractions: false,
      takenActions: false);
  late int infractionsNumber = 0;
  @override
  void initState() {
    super.initState();
    licensePlateService = LicensePlateService();
    infractionsService = InfractionService();
    getLicensePlate(widget.id);
  }

  void getLicensePlate(int id) async {
    var response = await licensePlateService.getLicensePlateById(id.toString());
    final Map<String, dynamic> decodedlicensePlateResponse =
        json.decode(response!.body)["licensePlate"];

    response = await infractionsService.getInfractionByLicensePlateId(
        decodedlicensePlateResponse["id"].toString());
    final List<dynamic> decodedInfractionsResponse =
        json.decode(response!.body)?["infraction"];
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
      );
      infractionsNumber = decodedInfractionsResponse.length;
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
          title: 'License Plate Details',
          onMenuPressed: openDrawer,
        ),
      ),
      drawer: Sidebar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // Top Part: Image and License Plate Code
          Expanded(
            flex: 2,
            child: Column(
              children: <Widget>[
                Image.network(
                  licensePlate.imageUrl,
                  fit: BoxFit.cover,
                ),
                SizedBox(height: 16.0),
                Text(
                  licensePlate.code,
                  style: TextStyle(fontSize: 28.0, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

          // Attributes: Longitude, Latitude, etc.
          Expanded(
            flex: 2,
            child: ListView(
              padding: EdgeInsets.all(16.0),
              children: <Widget>[
                _buildAttributeItem(Icons.location_on, 'Latitude',
                    licensePlate.latitude.toString()),
                _buildAttributeItem(Icons.location_on, 'Longitude',
                    licensePlate.longitude.toString()),
                _buildAttributeItem(Icons.warning, 'Infractions Number',
                    infractionsNumber.toString()),
                _buildAttributeItem(Icons.done, 'Taken Actions',
                    licensePlate.takenActions ? 'Yes' : 'No'),
              ],
            ),
          ),

          // Buttons: Add your buttons here
          Expanded(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  OwnerPage(licensePlateId: widget.id)));
                    },
                    child: Text('Owner'),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.lightBlue,
                        foregroundColor: Colors.white,
                        elevation: 2)),
                ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  InfractionsPage(licensePlateId: widget.id)));
                    },
                    child: Text('Infractions'),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.lightBlue,
                        foregroundColor: Colors.white,
                        elevation: 3)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttributeItem(IconData icon, String title, String value) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(value),
    );
  }
}
