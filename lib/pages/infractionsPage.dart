import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:lpdr_mobile/components/itemRow.dart';
import 'package:lpdr_mobile/components/sideBar.dart';
import 'package:lpdr_mobile/components/topbar.dart';
import 'package:lpdr_mobile/models/infractionModel.dart';
import 'package:lpdr_mobile/models/licensePlateModel.dart';
import 'package:lpdr_mobile/services/infractionService.dart';
import 'package:lpdr_mobile/services/licensePlateService.dart';

class InfractionsPage extends StatefulWidget {
  final int licensePlateId;

  InfractionsPage({required this.licensePlateId});

  @override
  _InfractionsPageState createState() => _InfractionsPageState();
}

class _InfractionsPageState extends State<InfractionsPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late final LicensePlateService licensePlateService;
  late final InfractionService infractionService;
  GlobalKey<AnimatedListState> listKey = GlobalKey<AnimatedListState>();

  late LicensePlate licensePlate = LicensePlate(
      id: 0,
      longitude: 0.0,
      latitude: 0.0,
      code: '',
      imageUrl: Uint8List.fromList([65, 66, 67, 68, 69]),
      hasInfractions: false,
      takenActions: false,
      userId: 0);

  List<Infraction> infractions = [];

  @override
  void initState() {
    super.initState();
    licensePlateService = LicensePlateService();
    infractionService = InfractionService();
    getInfractions(widget.licensePlateId);
  }

  void getInfractions(int licensePlateId) async {
    var response = await licensePlateService
        .getLicensePlateById(licensePlateId.toString());
    final Map<String, dynamic> decodedlicensePlateResponse =
        json.decode(response!.body)["licensePlate"];

    response = await infractionService.getInfractionByLicensePlateId(
        decodedlicensePlateResponse["id"].toString());
    final List<dynamic> decodedInfractionsResponse =
        json.decode(response!.body)?["infraction"];

    var infractionItems = decodedInfractionsResponse.map((data) {
      var responseDateTime = DateTime.parse(data['date']);
      return Infraction(
          id: data["id"],
          infractionCode: data["infractionCode"],
          ballotNumber: data["ballotNumber"],
          name: data["name"],
          level: data["level"],
          fine: data["fine"],
          licensePlateId: data["licensePlate"],
          date: responseDateTime);
    }).toList();

    final Uint8List imageBytes = await licensePlateService
        .getImageOfLicensePlate(decodedlicensePlateResponse["id"]);
    setState(() {
      licensePlate = LicensePlate(
          id: decodedlicensePlateResponse["id"],
          code: decodedlicensePlateResponse["code"],
          longitude: decodedlicensePlateResponse["longitude"],
          latitude: decodedlicensePlateResponse["latitude"],
          imageUrl: imageBytes,
          hasInfractions: decodedlicensePlateResponse["hasInfractions"],
          takenActions: decodedlicensePlateResponse["takenActions"],
          userId: decodedlicensePlateResponse["user"]);

      infractions = List.from(infractionItems);
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
          title: 'Infracciones',
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
            'Infracciones',
            style: TextStyle(fontSize: 40),
          ),
          SizedBox(height: 15), // Adjust the spacing as needed
          Expanded(
            child: ListView.builder(
              key: listKey,
              itemCount: infractions.length,
              itemBuilder: (BuildContext context, int index) {
                var infraction = infractions[index];
                return Container(
                  decoration: BoxDecoration(
                    color:
                        Color.fromARGB(255, 253, 253, 253), // Background color
                    border: Border.all(
                      color: const Color.fromARGB(
                          255, 223, 223, 223), // Border color
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
                        ItemRow(
                            icon: Icons.description,
                            text: infraction.infractionCode ?? ""),
                        SizedBox(height: 15),
                        ItemRow(
                            icon: Icons.receipt_long,
                            text: infraction.ballotNumber ?? ""),
                        SizedBox(height: 15),
                        ItemRow(
                            icon: Icons.calendar_month,
                            text: infraction.date!.toLocal().toString()),
                        SizedBox(height: 15),
                        ItemRow(icon: Icons.description, text: infraction.name),
                        SizedBox(height: 15),
                        ItemRow(icon: Icons.warning, text: infraction.level),
                        SizedBox(height: 15),
                        ItemRow(
                            icon: Icons.savings,
                            text: "S/. ${infraction.fine}"),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
