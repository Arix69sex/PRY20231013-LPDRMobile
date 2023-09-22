import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:lpdr_mobile/components/messageSnackBar.dart';
import 'package:lpdr_mobile/components/sideBar.dart';
import 'package:lpdr_mobile/components/topbar.dart';
import 'package:lpdr_mobile/models/licensePlateModel.dart';
import 'package:lpdr_mobile/pages/infractionsPage.dart';
import 'package:lpdr_mobile/pages/ownerPage.dart';
import 'package:lpdr_mobile/services/infractionService.dart';
import 'package:lpdr_mobile/services/licensePlateService.dart';
import 'package:lpdr_mobile/services/ownerService.dart';

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
  late final OwnerService ownerService;
  late LicensePlate licensePlate = LicensePlate(
      id: 0,
      longitude: 0.0,
      latitude: 0.0,
      code: 'TEST123',
      imageUrl: Uint8List.fromList([65, 66, 67, 68, 69]),
      hasInfractions: false,
      takenActions: false,
      userId: 0);
  late int infractionsNumber = 0;
  @override
  void initState() {
    super.initState();
    licensePlateService = LicensePlateService();
    ownerService = OwnerService();
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

    final Uint8List imageBytes = await licensePlateService
        .getImageOfLicensePlate(decodedlicensePlateResponse["id"]);
    setState(() {
      var responseDateTime =  DateTime.parse(decodedlicensePlateResponse['createdAt']);
      licensePlate = LicensePlate(
          id: decodedlicensePlateResponse["id"],
          code: decodedlicensePlateResponse["code"],
          longitude: decodedlicensePlateResponse["longitude"],
          latitude: decodedlicensePlateResponse["latitude"],
          imageUrl: imageBytes,
          hasInfractions: decodedlicensePlateResponse["hasInfractions"],
          takenActions: decodedlicensePlateResponse["takenActions"],
          createdAt: responseDateTime,
          userId: decodedlicensePlateResponse["user"]);
      infractionsNumber = decodedInfractionsResponse.length;
    });
  }

  Future<bool> hasOwner() async {
    var response =
        await ownerService.getOwnerByLicensePlateId(licensePlate.id.toString());

    final decodedResponse = json.decode(response!.body)?["owner"];

    return decodedResponse.isNotEmpty;
  }

  Future<bool> hasInfractions() async {
    var response = await infractionsService
        .getInfractionByLicensePlateId(licensePlate.id.toString());

    final List<dynamic> decodedResponse =
        json.decode(response!.body)?["infraction"];

    return decodedResponse.isNotEmpty;
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
            flex: 1,
            child: Column(
              children: <Widget>[
                SizedBox(height: 28.0),
                Image.memory(
                  licensePlate.imageUrl,
                  fit: BoxFit.cover,
                  width: 250,
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
                    licensePlate.latitude.toStringAsFixed(2).toString()),
                _buildAttributeItem(Icons.location_on, 'Longitude',
                    licensePlate.longitude.toStringAsFixed(2).toString()),
                _buildAttributeItem(Icons.today, 'Detected at',
                    licensePlate.createdAt != null ? licensePlate.createdAt!.toLocal().toString() : ""),
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
                /*ElevatedButton(
                    onPressed: () async {
                      var shouldRedirect = await hasOwner();
                      if (shouldRedirect) {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    OwnerPage(licensePlateId: widget.id)));
                      } else {
                        MessageSnackBar.showMessage(
                            context, "Owner not found.");
                      }
                    },
                    child: Text('Owner'),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.lightBlue,
                        foregroundColor: Colors.white,
                        elevation: 2)),*/
                ElevatedButton(
                    onPressed: () async {
                      var shouldRedirect = await hasInfractions();
                      if (shouldRedirect) {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => InfractionsPage(
                                    licensePlateId: widget.id)));
                      } else {
                        MessageSnackBar.showMessage(
                            context, "Infractions not found.");
                      }
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
